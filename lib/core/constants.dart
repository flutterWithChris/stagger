import 'dart:convert';
import 'dart:math';

import 'package:buoy/features/riders/model/rider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:rxdart/rxdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

const String privacyPolicyUrl =
    'https://gist.github.com/flutterWithChris/9e87960abbb88ab0184a7c11cff7ed6f';

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

// Get Neutral Snackbar
SnackBar getNeutralSnackbar(String message) {
  return SnackBar(
      content: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const Icon(Icons.info, color: Colors.white, size: 20),
          const SizedBox(width: 10),
          Text(message,
              style: const TextStyle(color: Colors.white),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ],
      ),
      backgroundColor: Colors.grey[800]);
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

EventTransformer<T> debounce<T>(Duration duration) {
  return (events, mapper) => events.debounceTime(duration).flatMap(mapper);
}

/// Throttle transformer to limit event firing frequency
EventTransformer<T> throttle<T>(Duration duration) {
  return (events, mapper) => events.throttleTime(duration).switchMap(mapper);
}

Chip buildRiderStyleChip(BuildContext context, RidingStyle ridingStyle) {
  return Chip(
    avatar: Icon(
      switch (ridingStyle) {
        RidingStyle.cruiser => PhosphorIcons.mountains(
            PhosphorIconsStyle.fill,
          ),
        RidingStyle.balanced => PhosphorIcons.motorcycle(
            PhosphorIconsStyle.fill,
          ),
        RidingStyle.fast => PhosphorIcons.flagCheckered(
            PhosphorIconsStyle.fill,
          ),
        null => PhosphorIcons.motorcycle(
            PhosphorIconsStyle.fill,
          ),
      },
      color: Colors.orange[300],
      size: 18,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    label: Text.rich(
      TextSpan(
        text: ' ${ridingStyle.name.enumToString()} Rider',
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    ),
  );
}
