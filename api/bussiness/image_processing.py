import cv2
from imutils.perspective import four_point_transform
import numpy as np
from model.Sheet import Sheet


def order_points(pts):
    rect = np.zeros((4, 2), dtype="float32")
    s = pts.sum(axis=1)
    rect[0] = pts[np.argmin(s)]
    rect[2] = pts[np.argmax(s)]
    diff = np.diff(pts, axis=1)
    rect[1] = pts[np.argmin(diff)]
    rect[3] = pts[np.argmax(diff)]
    return rect


def four_point_transform(image, pts):
    rect = order_points(pts)
    (tl, tr, br, bl) = rect
    widthA = np.sqrt(((br[0] - bl[0]) ** 2) + ((br[1] - bl[1]) ** 2))
    widthB = np.sqrt(((tr[0] - tl[0]) ** 2) + ((tr[1] - tl[1]) ** 2))
    maxWidth = max(int(widthA), int(widthB))
    heightA = np.sqrt(((tr[0] - br[0]) ** 2) + ((tr[1] - br[1]) ** 2))
    heightB = np.sqrt(((tl[0] - bl[0]) ** 2) + ((tl[1] - bl[1]) ** 2))
    maxHeight = max(int(heightA), int(heightB))
    dst = np.array([
        [0, 0],
        [maxWidth - 1, 0],
        [maxWidth - 1, maxHeight - 1],
        [0, maxHeight - 1]], dtype="float32")
    M = cv2.getPerspectiveTransform(rect, dst)
    warped = cv2.warpPerspective(image, M, (maxWidth, maxHeight))
    return warped


def warp_image_to_borders(image, border_thickness=12):
    gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
    blurred = cv2.GaussianBlur(gray, (7, 7), 0)
    thresh = cv2.adaptiveThreshold(blurred, 255, cv2.ADAPTIVE_THRESH_GAUSSIAN_C, cv2.THRESH_BINARY_INV, 71, 11)
    edged = cv2.Canny(thresh, 75, 200)

    contours, _ = cv2.findContours(edged, cv2.RETR_LIST, cv2.CHAIN_APPROX_SIMPLE)
    contours = sorted(contours, key=cv2.contourArea, reverse=True)

    for contour in contours:
        epsilon = 0.01 * cv2.arcLength(contour, True)
        approx = cv2.approxPolyDP(contour, epsilon, True)
        if len(approx) == 4:
            screen_cnt = approx
            break

    inner_contour = screen_cnt.reshape(4, 2) + border_thickness * np.array([[1, 1], [1, -1], [-1, -1], [-1, 1]])

    warped = four_point_transform(image, inner_contour)
    h, w = warped.shape[:2]
    new_width = min(w, 400)
    scale_ratio = new_width / w
    new_height = int(h * scale_ratio)
    warped = cv2.resize(warped, (new_width, new_height))
    return warped


def sort_bubbles_into_rows(bubbles, tolerance=5):
    sorted_bubbles = sorted(bubbles, key=lambda b: b[1])
    rows = []
    current_row = []
    last_y = None

    for bubble in sorted_bubbles:
        x, y, w, h = bubble
        if last_y is None or abs(y - last_y) <= tolerance:
            current_row.append(bubble)
        else:
            current_row = sorted(current_row, key=lambda b: b[0])
            rows.append(current_row)
            current_row = [bubble]
        last_y = y

    if current_row:
        # Son satırı X koordinatlarına göre sırala
        current_row = sorted(current_row, key=lambda b: b[0])
        rows.append(current_row)

    return rows


def detect_bubbles(image):
    gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
    thresh = cv2.adaptiveThreshold(gray, 255, cv2.ADAPTIVE_THRESH_GAUSSIAN_C, cv2.THRESH_BINARY_INV, 101, 11)
    contours, _ = cv2.findContours(thresh, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_NONE)

    filtered_contours_img = image.copy()

    bubbles = []
    i = 0
    for contour in contours:
        if cv2.contourArea(contour) > 500:
            x, y, w, h = cv2.boundingRect(contour)
            aspect_ratio = w / float(h)
            i += 1
            if 0.8 < aspect_ratio < 1.2:
                cv2.drawContours(filtered_contours_img, [contour], -1, (0, 255, 0), 1)
                bubbles.append((x, y, w, h))

    bubbles = sort_bubbles_into_rows(bubbles, tolerance=5)
    filled_bubbles = []
    # annotated_image = image.copy()  # Annotated image with text
    options = 0
    for i, row in enumerate(bubbles):  # Düzeltme yapıldı, 'bubbles' kullanılmalı
        filled_indices = []
        options = max(options, len(row))
        for j, (x, y, w, h) in enumerate(row):

            # bubble_roi = cleaned[y:y+h, x:x+w]
            bubble_roi = thresh[y:y + h, x:x + w]

            # Create a mask for circular area
            radius = min(w, h) // 2
            circle_mask = np.zeros((h, w), dtype="uint8")
            cv2.circle(circle_mask, (w // 2, h // 2), radius, 255, -1)

            # Apply the mask
            bubble_roi = cv2.bitwise_and(bubble_roi, bubble_roi, mask=circle_mask)

            total_circle_area = np.sum(circle_mask > 0)
            black_pixels = np.sum(bubble_roi < 128)
            black_ratio = black_pixels / total_circle_area

            # print(f"Row {i+1}, Bubble {j+1}: Black Ratio = {black_ratio:.2f}")

            # Annotate the image with the black ratio
            # cv2.putText(annotated_image, f"{black_ratio:.2f}", (x, y + h // 2),
            #             cv2.FONT_HERSHEY_SIMPLEX, 0.4, (255, 0, 0), 1, cv2.LINE_AA)

            if black_ratio < 0.85:
                filled_indices.append(j)
        filled_bubbles.append(filled_indices)
    filled_bubbles.insert(0, options)
    return filled_bubbles


def process_image(sheet: Sheet):
    print(sheet.image_path)
    image = cv2.imread(sheet.image_path)
    warped = warp_image_to_borders(image)
    rows = detect_bubbles(warped)
    options = rows.pop(0)
    result = []

    empty_count = 0
    multi_answer_count = 0
    for answer in rows:
        if len(answer) == 0:
            result.append("-")
            empty_count += 1
        elif len(answer) == 1:
            result.append(chr(65 + answer[0]))
        elif len(answer) > 1:
            result.append("X")
            multi_answer_count += 1
        else:
            result.append("-")

    sheet.answers = result
    sheet.question_count = len(result)
    sheet.empty_count = empty_count
    sheet.multi_answer_count = multi_answer_count
    sheet.options = options
    return sheet
