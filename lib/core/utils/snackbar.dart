// * on [Success] state

import 'package:delightful_toast/delight_toast.dart';
import 'package:delightful_toast/toast/components/toast_card.dart';
import 'package:flutter/material.dart';

void successBar(BuildContext ctx, String txt) {
  return DelightToastBar(
    autoDismiss: true,
    snackbarDuration: const Duration(seconds: 2),
    animationDuration: const Duration(seconds: 1),
    builder: (ctx) => ToastCard(
      color: Colors.green,
      leading: const Icon(
        Icons.check_circle,
        color: Colors.white,
        size: 28,
      ),
      title: Text(
        txt,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
  ).show(ctx);
}

// ! on [Error] state
void errorBar(BuildContext ctx, String txt) {
  return DelightToastBar(
    autoDismiss: true,
    snackbarDuration: const Duration(seconds: 2),
    animationDuration: const Duration(seconds: 1),
    builder: (ctx) => ToastCard(
      color: Colors.red,
      leading: const Icon(
        Icons.error,
        color: Colors.white,
        size: 28,
      ),
      title: Text(
        txt,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
  ).show(ctx);
}

// ? on [Loading] state
void loadingBar(BuildContext ctx, String txt) {
  return DelightToastBar(
    autoDismiss: true,
    snackbarDuration: const Duration(seconds: 2),
    animationDuration: const Duration(seconds: 1),
    builder: (ctx) => ToastCard(
      color: Colors.amber,
      leading: const Icon(
        Icons.error,
        color: Colors.white,
        size: 28,
      ),
      title: Text(
        txt,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
  ).show(ctx);
}
