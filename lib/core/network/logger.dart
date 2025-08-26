import 'package:flutter/material.dart';

void printLog(String label, String message) {
  String color = "";

  if (label.toLowerCase() == "err") {
    color = colors['red'].toString();
    // debugPrint("${colors['red']} $label: $message");
  } else if (label.toLowerCase() == "warn") {
    color = colors['yellow'].toString();
  } else {
    color = colors['blue'].toString();
  }

  debugPrint("$color [$label] : $message");
}

const colors = {
  'red': '\x1B[31m',
  'blue': '\x1B[34m',
  'yellow': '\x1B[33m',
};
