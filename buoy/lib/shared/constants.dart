import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

// Show snackbar
void showSnackbar(String message, {bool isError = false}) {
  scaffoldMessengerKey.currentState!.showSnackBar(getSuccessSnackbar(message));
}

void showErrorSnackbar(String message) {
  scaffoldMessengerKey.currentState!.showSnackBar(getErrorSnackbar(message));
}

String generateRandomKey(int length) {
  final random = Random.secure();
  final values = List<int>.generate(length, (i) => random.nextInt(256));
  return base64UrlEncode(values);
}

// getSuccessSnackbar
SnackBar getSuccessSnackbar(String message) {
  return SnackBar(
    content: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const Icon(Icons.check,
            color: Colors.white, size: 20, semanticLabel: 'Success'),
        const SizedBox(width: 10),
        Text(
          message,
          style: const TextStyle(
            color: Colors.white,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    ),
    backgroundColor: Colors.green,
  );
}

// getErrorSnackbar
SnackBar getErrorSnackbar(String message) {
  return SnackBar(
    content: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const Icon(Icons.error, color: Colors.white, size: 20),
        const SizedBox(width: 10),
        Text(message,
            style: const TextStyle(color: Colors.white),
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
      ],
    ),
    backgroundColor: Colors.red,
  );
}

// Extension to convert enum to Title Case & Spaces at Capital Letters
extension EnumToString on String {
  String enumToString() {
    return replaceAllMapped(RegExp(r'[A-Z]'), (match) => ' ${match.group(0)}')
        .trim()
        .toTitleCase();
  }
}

// Title Case Extension
extension TitleCase on String {
  String toTitleCase() {
    return split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
}
