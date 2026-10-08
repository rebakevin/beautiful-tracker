import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../member.dart';

/// A tinted pill showing how many of a member's tasks are in a given status
/// (e.g. "1 overdue"), color-coded by the status.
class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status, required this.count});

  final TaskStatus status;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: ShapeDecoration(
        color: status.background,
        shape: const StadiumBorder(),
      ),
      child: Text(
        '$count ${status.label}',
        style: GoogleFonts.barlow(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: status.foreground,
        ),
      ),
    );
  }
}
