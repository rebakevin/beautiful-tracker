import 'dart:async';

import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

OverlayEntry? _current;
Timer? _timer;

/// Uses the root overlay, so it stays visible when the current screen closes
/// right after showing it (for example after saving a form).
void showToast(BuildContext context, String message) {
  final overlay = Overlay.of(context, rootOverlay: true);
  _timer?.cancel();
  _current?.remove();

  final entry = OverlayEntry(
    builder: (context) => Positioned(
      left: 24,
      right: 24,
      bottom: 100,
      child: IgnorePointer(
        child: Center(
          child: Material(
            color: AppColors.scrim,
            shape: const StadiumBorder(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  _current = entry;
  overlay.insert(entry);
  _timer = Timer(const Duration(seconds: 2), () {
    entry.remove();
    if (_current == entry) _current = null;
  });
}
