import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../member.dart';

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
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          color: status.foreground,
        ),
      ),
    );
  }
}
