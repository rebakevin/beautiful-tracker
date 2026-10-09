import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../models/task.dart';
import '../utils/task_date.dart';
import 'task_badges.dart';

class TaskCard extends StatelessWidget {
  const TaskCard({super.key, required this.task, required this.onTap});

  final Task task;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.cardPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      task.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleMedium,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  SlaBadge(sla: task.sla),
                ],
              ),
              if (task.description.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  task.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyMedium,
                ),
              ],
              const SizedBox(height: AppSpacing.sm),
              Text(
                '${task.assignee} · Due ${formatTaskDate(task.dueDate)}',
                style: textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: [
                  NeutralPill(label: task.status.label),
                  NeutralPill(label: '${task.priority.label} priority'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
