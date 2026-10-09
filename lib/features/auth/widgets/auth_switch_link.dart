import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_palette.dart';

/// A single rich text, so it wraps onto two lines on narrow screens or with
/// large system font sizes instead of overflowing.
class AuthSwitchLink extends StatefulWidget {
  const AuthSwitchLink({
    super.key,
    required this.prompt,
    required this.action,
    required this.onTap,
  });

  final String prompt;
  final String action;
  final VoidCallback onTap;

  @override
  State<AuthSwitchLink> createState() => _AuthSwitchLinkState();
}

class _AuthSwitchLinkState extends State<AuthSwitchLink> {
  // Recognizers hold resources, so they are created once and disposed.
  late final _tap = TapGestureRecognizer()..onTap = () => widget.onTap();

  @override
  void dispose() {
    _tap.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyMedium;
    return Text.rich(
      TextSpan(
        style: style,
        children: [
          TextSpan(text: '${widget.prompt} '),
          TextSpan(
            text: widget.action,
            recognizer: _tap,
            style: TextStyle(
              color: context.palette.accent,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}
