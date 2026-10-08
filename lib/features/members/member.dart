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
    required this.name,
    required this.email,
    required this.initials,
    required this.taskCount,
    required this.statuses,
  });

  final String name;
  final String email;
  final String initials;
  final int taskCount;
  final List<TaskStatusCount> statuses;
}

/// Sample roster used to render the members page until real data are connected.
const List<Member> sampleMembers = [
  Member(
    name: 'Kevin Rebakure',
    email: 'kevin@pace.dev',
    initials: 'KR',
    taskCount: 3,
    statuses: [
      TaskStatusCount(TaskStatus.overdue, 1),
      TaskStatusCount(TaskStatus.atRisk, 1),
      TaskStatusCount(TaskStatus.onTrack, 1),
    ],
  ),
  Member(
    name: 'Alice Uwase',
    email: 'alice@pace.dev',
    initials: 'AU',
    taskCount: 2,
    statuses: [
      TaskStatusCount(TaskStatus.onTrack, 1),
      TaskStatusCount(TaskStatus.done, 1),
    ],
  ),
  Member(
    name: 'Eric Mugisha',
    email: 'eric@pace.dev',
    initials: 'EM',
    taskCount: 2,
    statuses: [
      TaskStatusCount(TaskStatus.overdue, 1),
      TaskStatusCount(TaskStatus.atRisk, 1),
    ],
  ),
  Member(
    name: 'Diane Ingabire',
    email: 'diane@pace.dev',
    initials: 'DI',
    taskCount: 2,
    statuses: [
      TaskStatusCount(TaskStatus.onTrack, 1),
      TaskStatusCount(TaskStatus.done, 1),
    ],
  ),
];
