import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

void showToast(FToast fToast, String message, Color textColor, Color background, IconData icon) {
  Widget toast = Container(
    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(25.0),
      color: background,
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: textColor),
        const SizedBox(
          width: 12.0,
        ),
        Text(message, style: TextStyle(color: textColor)),
      ],
    ),
  );
  fToast.showToast(
    child: toast,
    gravity: ToastGravity.BOTTOM,
    toastDuration: const Duration(seconds: 1),
  );
}

void showSuccessToast(FToast fToast, String message) {
  showToast(fToast, message, Colors.white, Colors.green[600]!, Icons.check);
}

void showInfoToast(FToast fToast, String message) {
  showToast(fToast, message, Colors.white, Colors.grey[600]!, Icons.info);
}

void showWarningToast(FToast fToast, String message) {
  showToast(fToast, message, Colors.white, Colors.yellow[600]!, Icons.warning);
}

void showErrorToast(FToast fToast, String message) {
  showToast(fToast, message, Colors.white, Colors.red[600]!, Icons.error);
}

void showDeletedToast(FToast fToast, String message) {
  showToast(fToast, message, Colors.white, Colors.red[600]!, Icons.delete);
}

void showSavedToast(FToast fToast, String message) {
  showToast(fToast, message, Colors.white, Colors.green[600]!, Icons.save);
}