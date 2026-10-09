import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_spacing.dart';

class TaskStatsCard extends StatelessWidget {
  const TaskStatsCard({
    super.key,
    required this.total,
    required this.completed,
    required this.inProgress,
    required this.overdue,
  });

  final int total;
  final int completed;
  final int inProgress;
  final int overdue;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        child: Column(
          children: [
            _StatRow(
              label: 'Total Tasks',
              count: total,
              total: total,
              color: AppColors.primary,
            ),
            const SizedBox(height: AppSpacing.md),
            _StatRow(
              label: 'Completed',
              count: completed,
              total: total,
              color: AppColors.chartCompleted,
            ),
            const SizedBox(height: AppSpacing.md),
            _StatRow(
              label: 'In Progress',
              count: inProgress,
              total: total,
              color: AppColors.chartInProgress,
            ),
            const SizedBox(height: AppSpacing.md),
            _StatRow(
              label: 'Overdue',
              count: overdue,
              total: total,
              color: AppColors.danger,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.label,
    required this.count,
    required this.total,
    required this.color,
  });

  final String label;
  final int count;
  final int total;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final style = TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w600,
      color: palette.ink,
    );

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Text(label, style: style)),
            Text('$count', style: style.copyWith(fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: total == 0 ? 0 : count / total,
            minHeight: 10,
            color: color,
            backgroundColor: palette.hairline,
          ),
        ),
      ],
    );
  }
}
