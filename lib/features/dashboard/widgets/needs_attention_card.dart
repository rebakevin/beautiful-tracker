import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_spacing.dart';
import '../../tasks/models/task.dart';
import '../../tasks/utils/task_date.dart';
import '../../tasks/widgets/task_badges.dart';

class NeedsAttentionCard extends StatelessWidget {
  const NeedsAttentionCard({
    super.key,
    required this.task,
    required this.onTap,
  });

  final Task task;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final due = formatTaskDateShort(task.dueDate);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.cardPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                task.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text('${task.assignee} · Due $due', style: textTheme.bodyMedium),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  SlaBadge(sla: task.sla),
                  NeutralPill(label: task.status.label),
                  _PriorityIndicator(priority: task.priority),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PriorityIndicator extends StatelessWidget {
  const _PriorityIndicator({required this.priority});

  final TaskPriority priority;

  int get _level => switch (priority) {
    TaskPriority.low => 1,
    TaskPriority.medium => 2,
    TaskPriority.high => 3,
  };

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(width: AppSpacing.xxs),
        for (var i = 1; i <= 3; i++) ...[
          Container(
            width: 4,
            height: 4.0 + i * 3,
            decoration: BoxDecoration(
              color: i <= _level ? AppColors.primary : palette.border,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
          if (i < 3) const SizedBox(width: 2),
        ],
        const SizedBox(width: AppSpacing.xs),
        Text(
          priority.label,
          style: TextStyle(fontSize: 12.5, color: palette.muted),
        ),
      ],
    );
  }
}
