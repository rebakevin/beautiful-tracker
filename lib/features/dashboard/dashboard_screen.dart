import 'package:flutter/material.dart';

import '../../core/session/session_scope.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/app_spacing.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/initials_avatar.dart';
import '../tasks/data/task_repository.dart';
import '../tasks/models/task.dart';
import '../tasks/screens/task_details_screen.dart';
import 'widgets/needs_attention_card.dart';
import 'widgets/task_stats_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    super.key,
    this.refreshToken = 0,
    this.onViewAllTasks,
  });

  /// Bump this to make the dashboard reload (the shell does it on tab switch).
  final int refreshToken;

  final VoidCallback? onViewAllTasks;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _repository = TaskRepository();

  List<Task> _tasks = [];
  List<Task> _attention = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  @override
  void didUpdateWidget(DashboardScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshToken != widget.refreshToken) _loadTasks();
  }

  Future<void> _loadTasks() async {
    try {
      final tasks = await _repository.getAll();
      if (!mounted) return;
      setState(() {
        _tasks = tasks;
        _attention = _needsAttention(tasks);
        _loading = false;
        _error = null;
      });
    } catch (e, st) {
      debugPrint('Failed to load dashboard tasks: $e\n$st');
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Could not load tasks.';
      });
    }
  }

  Future<void> _openDetails(Task task) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => TaskDetailsScreen(task: task)),
    );
    if (changed == true) _loadTasks();
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 18) return 'Good afternoon';
    return 'Good evening';
  }

  /// Overdue and at-risk tasks that are still open, earliest deadline first.
  static List<Task> _needsAttention(List<Task> tasks) =>
      tasks
          .where(
            (t) =>
                t.status != TaskStatus.completed &&
                (t.sla == SlaStatus.overdue || t.sla == SlaStatus.atRisk),
          )
          .toList()
        ..sort((a, b) => a.dueDate.compareTo(b.dueDate));

  @override
  Widget build(BuildContext context) {
    final user = SessionScope.of(context).user;
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        onRefresh: _loadTasks,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.screen),
          children: [
            Row(
              children: [
                const AppLogo(width: 34),
                const SizedBox(width: AppSpacing.sm),
                Text('Beautiful Tracker', style: textTheme.titleLarge),
              ],
            ),
            const SizedBox(height: AppSpacing.screen),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user == null
                            ? _greeting
                            : '$_greeting, ${user.firstName}',
                        style: textTheme.headlineMedium,
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        "Here's what's happening with your team.",
                        style: textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                if (user != null) ...[
                  const SizedBox(width: AppSpacing.md),
                  InitialsAvatar(
                    initials: user.initials,
                    imagePath: user.avatarPath,
                    size: 46,
                    background: AppColors.yellow400,
                    foreground: AppColors.brownInk,
                  ),
                ],
              ],
            ),
            const SizedBox(height: AppSpacing.section),
            ..._buildBody(context),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildBody(BuildContext context) {
    if (_loading) {
      return const [
        Padding(
          padding: EdgeInsets.only(top: AppSpacing.section),
          child: Center(child: CircularProgressIndicator()),
        ),
      ];
    }
    if (_error != null) {
      return [
        Padding(
          padding: const EdgeInsets.only(top: AppSpacing.section),
          child: EmptyState(icon: Icons.error_outline, message: _error!),
        ),
      ];
    }

    final attention = _attention;
    final textTheme = Theme.of(context).textTheme;

    return [
      TaskStatsCard(
        total: _tasks.length,
        completed: _tasks.where((t) => t.status == TaskStatus.completed).length,
        inProgress: _tasks
            .where((t) => t.status == TaskStatus.inProgress)
            .length,
        overdue: _tasks.where((t) => t.sla == SlaStatus.overdue).length,
      ),
      const SizedBox(height: AppSpacing.section),
      Row(
        children: [
          Expanded(child: Text('Needs Attention', style: textTheme.titleLarge)),
          TextButton(
            onPressed: widget.onViewAllTasks,
            style: TextButton.styleFrom(
              foregroundColor: context.palette.accent,
              padding: EdgeInsets.zero,
              minimumSize: const Size(0, 32),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              textStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            child: const Text('View all tasks'),
          ),
        ],
      ),
      const SizedBox(height: AppSpacing.md),
      if (attention.isEmpty)
        const Padding(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.section),
          child: EmptyState(
            icon: Icons.task_alt_outlined,
            message: 'Nothing needs attention right now.',
          ),
        )
      else
        for (final task in attention) ...[
          NeedsAttentionCard(task: task, onTap: () => _openDetails(task)),
          const SizedBox(height: AppSpacing.listGap),
        ],
    ];
  }
}
