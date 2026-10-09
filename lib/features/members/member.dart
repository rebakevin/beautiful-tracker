import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

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

class TaskStatusCount {
  const TaskStatusCount(this.status, this.count);

  final TaskStatus status;
  final int count;
}

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

  Member copyWith({int? taskCount, List<TaskStatusCount>? statuses}) {
    return Member(
      id: id,
      name: name,
      email: email,
      initials: initials,
      taskCount: taskCount ?? this.taskCount,
      statuses: statuses ?? this.statuses,
    );
  }

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
