import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// The health state of a member's tasks, used to color-code status badges.
enum TaskStatus {
  overdue('overdue', AppColors.overdueBg, AppColors.overdueFg),
  atRisk('at risk', AppColors.atRiskBg, AppColors.atRiskFg),
  onTrack('on track', AppColors.onTrackBg, AppColors.onTrackFg),
  done('done', AppColors.completedBg, AppColors.completedFg);

  const TaskStatus(this.label, this.background, this.foreground);

  final String label;
  final Color background;
  final Color foreground;
}

/// A count of tasks in a single TaskStatus.
class TaskStatusCount {
  const TaskStatusCount(this.status, this.count);

  final TaskStatus status;
  final int count;
}

/// A team member shown in the members list.
class Member {
  const Member({
    this.id,
    required this.name,
    required this.email,
    required this.initials,
    required this.taskCount,
    required this.statuses,
  });

  final int? id;
  final String name;
  final String email;
  final String initials;
  final int taskCount;
  final List<TaskStatusCount> statuses;

  /// Derives initials from a full name: the first character of each of the
  /// first two names (so "Alice Uwase Mireille" becomes "AU").
  static String initialsFromName(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '';
    final buffer = StringBuffer(parts.first[0].toUpperCase());
    if (parts.length > 1) {
      buffer.write(parts[1][0].toUpperCase());
    }
    return buffer.toString();
  }
}
