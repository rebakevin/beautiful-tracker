import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../models/task.dart';

/// Tinted pill showing a task's SLA status. Reserved for SLA only.
class SlaBadge extends StatelessWidget {
  const SlaBadge({super.key, required this.sla});

  final SlaStatus sla;

  Color get _background => switch (sla) {
    SlaStatus.onTrack => AppColors.onTrackBg,
    SlaStatus.atRisk => AppColors.atRiskBg,
    SlaStatus.overdue => AppColors.overdueBg,
    SlaStatus.completed => AppColors.completedBg,
  };

  Color get _foreground => switch (sla) {
    SlaStatus.onTrack => AppColors.onTrackFg,
    SlaStatus.atRisk => AppColors.atRiskFg,
    SlaStatus.overdue => AppColors.overdueFg,
    SlaStatus.completed => AppColors.completedFg,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: _background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        sla.label,
        style: TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          color: _foreground,
        ),
      ),
    );
  }
}

class NeutralPill extends StatelessWidget {
  const NeutralPill({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w500,
          color: AppColors.ink2,
        ),
      ),
    );
  }
}
