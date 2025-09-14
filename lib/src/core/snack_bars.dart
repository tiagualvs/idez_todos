import 'package:flutter/material.dart';

mixin SnackBars<T extends StatefulWidget> on State<T> {
  void showSnacBar(String message, {Color? backgroundColor}) {
    removeCurrentSnackBar();
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(message),
        backgroundColor: backgroundColor,
      ),
    );
  }

  void showSuccessSnackBar(String message) {
    return showSnacBar(message, backgroundColor: Colors.green);
  }

  void showErrorSnackBar(String message) {
    return showSnacBar(message, backgroundColor: Colors.red);
  }

  void removeCurrentSnackBar() {
    return ScaffoldMessenger.maybeOf(context)?.removeCurrentSnackBar();
  }
}
