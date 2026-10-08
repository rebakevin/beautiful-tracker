import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../data/task_repository.dart';
import '../models/task.dart';
import '../utils/task_date.dart';
import '../widgets/task_badges.dart';
import 'create_edit_task_screen.dart';

/// Read-only view of one task with Edit, Delete and Change Status actions.
/// Pops with true when something changed, so the list knows to reload.
class TaskDetailsScreen extends StatefulWidget {
  const TaskDetailsScreen({super.key, required this.task});

  final Task task;

  @override
  State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  final _repository = TaskRepository();
  late Task _task;
  bool _changed = false;

  @override
  void initState() {
    super.initState();
    _task = widget.task;
  }

  void _close() => Navigator.of(context).pop(_changed);

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  /// Lets the user pick a new workflow status from a bottom sheet.
  Future<void> _changeStatus() async {
    final picked = await showModalBottomSheet<TaskStatus>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.sheet),
        ),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(AppSpacing.cardPadding),
              child: Text(
                'Change status',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
            ),
            for (final s in TaskStatus.values)
              ListTile(
                title: Text(s.label),
                trailing: s == _task.status
                    ? const Icon(Icons.check, color: AppColors.primary)
                    : null,
                onTap: () => Navigator.of(context).pop(s),
              ),
          ],
        ),
      ),
    );
    if (picked == null || picked == _task.status) return;

    // A completed task is classified Completed. Reopening it resets the SLA
    // status to On Track until the automatic SLA logic takes over.
    final SlaStatus newSla;
    if (picked == TaskStatus.completed) {
      newSla = SlaStatus.completed;
    } else if (_task.sla == SlaStatus.completed) {
      newSla = SlaStatus.onTrack;
    } else {
      newSla = _task.sla;
    }

    final updated = _task.copyWith(status: picked, sla: newSla);
    try {
      await _repository.update(updated);
      if (!mounted) return;
      setState(() {
        _task = updated;
        _changed = true;
      });
    } catch (_) {
      if (!mounted) return;
      _showError('Could not update the status. Try again.');
    }
  }

  /// Opens the form in edit mode and reloads this task if it was saved.
  Future<void> _edit() async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => CreateEditTaskScreen(task: _task)),
    );
    if (saved != true) return;

    final fresh = await _repository.getById(_task.id!);
    if (!mounted) return;
    if (fresh == null) {
      Navigator.of(context).pop(true);
      return;
    }
    setState(() {
      _task = fresh;
      _changed = true;
    });
  }

  /// Asks for confirmation, then deletes the task and goes back to the list.
  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.dialog),
        ),
        title: const Text('Delete task?'),
        content: const Text('This task will be permanently removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await _repository.delete(_task.id!);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      _showError('Could not delete the task. Try again.');
    }
  }

  Widget _row(String label, Widget value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ),
          Expanded(child: value),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final initial = _task.assignee.isEmpty
        ? '?'
        : _task.assignee[0].toUpperCase();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _close();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _close,
          ),
          title: const Text('Task Details'),
          backgroundColor: AppColors.ground,
          foregroundColor: AppColors.ink,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.screen),
            children: [
              Text(_task.title, style: textTheme.headlineMedium),
              const SizedBox(height: AppSpacing.md),
              Align(
                alignment: Alignment.centerLeft,
                child: SlaBadge(sla: _task.sla),
              ),
              const SizedBox(height: AppSpacing.section),
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.cardPadding,
                  ),
                  child: Column(
                    children: [
                      _row(
                        'Description',
                        Text(
                          _task.description.isEmpty
                              ? 'No description'
                              : _task.description,
                          style: textTheme.bodyLarge,
                        ),
                      ),
                      const Divider(),
                      _row(
                        'Assigned to',
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 12,
                              backgroundColor: AppColors.yellow200,
                              child: Text(
                                initial,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.brownInk,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Text(_task.assignee, style: textTheme.bodyLarge),
                          ],
                        ),
                      ),
                      const Divider(),
                      _row(
                        'Due date',
                        Text(
                          formatTaskDate(_task.dueDate),
                          style: textTheme.bodyLarge,
                        ),
                      ),
                      const Divider(),
                      _row(
                        'Priority',
                        Align(
                          alignment: Alignment.centerLeft,
                          child: NeutralPill(label: _task.priority.label),
                        ),
                      ),
                      const Divider(),
                      _row(
                        'Status',
                        Align(
                          alignment: Alignment.centerLeft,
                          child: NeutralPill(label: _task.status.label),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.section),
              FilledButton(
                onPressed: _changeStatus,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.field),
                  ),
                ),
                child: const Text('Change Status'),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _edit,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 52),
                        foregroundColor: AppColors.ink,
                        side: const BorderSide(color: AppColors.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.field),
                        ),
                      ),
                      child: const Text('Edit'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _delete,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 52),
                        foregroundColor: AppColors.danger,
                        side: const BorderSide(color: AppColors.danger),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.field),
                        ),
                      ),
                      child: const Text('Delete'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
