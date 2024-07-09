from datetime import datetime
from flask import Flask, request, jsonify, render_template
import os

from bussiness.image_processing import process_image
from model.Sheet import Sheet

date_format = "%Y_%m_%d_%H_%M_%S"

app = Flask(__name__)


@app.route('/', methods=['GET'])
def index():
    return render_template("index.html", title="OMR API", action="/")


@app.route('/', methods=['POST'])
def process_answer_key_endpoint():
    file = request.files['image']
    file_path = f'./sheets/{datetime.now().strftime(date_format)}.jpg'
    file.save(file_path)

    sheet = Sheet()
    sheet.image_path = file_path
    try:
        sheet = process_image(sheet)
        print(f"Request Processed For Client: {request.remote_addr}")
    except Exception as e:
        print(f"Error Occurred For Client: {request.remote_addr}, Image Path: {sheet.image_path}, Error: {str(e)}")
        return jsonify({"error": str(e)}), 400
    return jsonify(sheet.__dict__)


if __name__ == '__main__':
    sheets_dir = './sheets/'
    if not os.path.exists(sheets_dir):
        os.makedirs(sheets_dir)
    app.run(host='0.0.0.0', debug=True)
