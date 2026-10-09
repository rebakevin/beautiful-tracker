import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../widgets/app_sheet.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/page_scaffold.dart';
import '../../data/repositories/member_repository.dart';
import '../members/member.dart' show Member;
import '../members/widgets/member_picker_sheet.dart';
import 'data/task_repository.dart';
import 'models/task.dart';
import 'screens/create_edit_task_screen.dart';
import 'screens/task_details_screen.dart';
import 'widgets/task_card.dart';

/// Wraps the sheet result so "All" (null) differs from dismissing.
class _FilterChoice<T> {
  const _FilterChoice(this.value);
  final T? value;
}

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final _repository = TaskRepository();
  final _memberRepository = const MemberRepository();
  final _searchController = TextEditingController();

  List<Task> _tasks = [];
  TaskStatus? _statusFilter;
  String? _assigneeFilter;
  bool _searching = false;
  String _query = '';
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTasks() async {
    try {
      final tasks = await _repository.getAll();
      if (!mounted) return;
      setState(() {
        _tasks = tasks;
        _loading = false;
        _error = null;
      });
    } catch (e, st) {
      debugPrint('Failed to load tasks: $e\n$st');
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Could not load tasks.';
      });
    }
  }

  Future<void> _openForm([Task? task]) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => CreateEditTaskScreen(task: task)),
    );
    if (saved == true) _loadTasks();
  }

  Future<void> _openDetails(Task task) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => TaskDetailsScreen(task: task)),
    );
    if (changed == true) _loadTasks();
  }

  List<Task> get _visibleTasks {
    final q = _query.trim().toLowerCase();
    return _tasks.where((t) {
      final matchesFilter = _statusFilter == null || t.status == _statusFilter;
      final matchesQuery =
          q.isEmpty ||
          t.title.toLowerCase().contains(q) ||
          t.assignee.toLowerCase().contains(q);
      final matchesAssignee =
          _assigneeFilter == null || t.assignee == _assigneeFilter;
      return matchesFilter && matchesQuery && matchesAssignee;
    }).toList();
  }

  String get _emptyMessage {
    if (_tasks.isEmpty) return 'No tasks available.';
    if (_query.trim().isNotEmpty) return 'No tasks match your filters.';

    final status = switch (_statusFilter) {
      TaskStatus.todo => 'to do',
      TaskStatus.inProgress => 'in progress',
      TaskStatus.completed => 'completed',
      null => null,
    };
    final who = _assigneeFilter;
    if (who != null) {
      return status == null
          ? '$who has no tasks.'
          : '$who has no tasks $status.';
    }
    if (status != null) return 'No tasks $status.';
    return 'No tasks match your filters.';
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: 'Tasks',
      actions: _buildHeaderActions(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_searching) ...[
            _buildSearchField(),
            const SizedBox(height: AppSpacing.md),
          ],
          _buildFilters(),
          const SizedBox(height: AppSpacing.md),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildHeaderActions() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: _toggleSearch,
          icon: Icon(_searching ? Icons.close : Icons.search),
          style: IconButton.styleFrom(
            minimumSize: const Size(44, 44),
            backgroundColor: AppColors.surface,
            foregroundColor: AppColors.ink,
            side: const BorderSide(color: AppColors.border),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        FilledButton.icon(
          onPressed: () => _openForm(),
          icon: const Icon(Icons.add),
          label: const Text('Add Task'),
          style: FilledButton.styleFrom(
            minimumSize: const Size(0, 44),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: const StadiumBorder(),
            textStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchField() {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.field),
      borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
    );

    return TextField(
      controller: _searchController,
      autofocus: true,
      onChanged: (value) => setState(() => _query = value),
      decoration: InputDecoration(
        hintText: 'Search tasks',
        isDense: true,
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.cardPadding,
          vertical: AppSpacing.md,
        ),
        enabledBorder: border,
        focusedBorder: border,
      ),
    );
  }

  void _toggleSearch() {
    setState(() {
      _searching = !_searching;
      if (!_searching) {
        _searchController.clear();
        _query = '';
      }
    });
  }

  Widget _buildFilters() {
    return Row(
      children: [
        _filterPill(
          _statusFilter?.label ?? 'Status',
          _openStatusSheet,
          active: _statusFilter != null,
        ),
        const SizedBox(width: AppSpacing.sm),
        _filterPill(
          _assigneeFilter ?? 'Assignee',
          _openAssigneeSheet,
          active: _assigneeFilter != null,
        ),
        const Spacer(),
        if (_statusFilter != null || _assigneeFilter != null)
          TextButton(
            onPressed: () => setState(() {
              _statusFilter = null;
              _assigneeFilter = null;
            }),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.ink2,
              textStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            child: const Text('Clear filters'),
          ),
      ],
    );
  }

  Widget _filterPill(String label, VoidCallback onTap, {bool active = false}) {
    return ActionChip(
      onPressed: onTap,
      backgroundColor: active ? AppColors.primaryTint : AppColors.surface,
      side: BorderSide(
        color: active ? AppColors.primaryBorder : AppColors.border,
      ),
      shape: const StadiumBorder(),
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: active ? AppColors.primary : AppColors.ink,
            ),
          ),
          Icon(
            Icons.arrow_drop_down,
            size: 20,
            color: active ? AppColors.primary : AppColors.ink,
          ),
        ],
      ),
    );
  }

  Future<void> _openStatusSheet() async {
    final result = await _showFilterSheet<TaskStatus>(
      title: 'Filter by status',
      allLabel: 'All statuses',
      options: [for (final s in TaskStatus.values) (s, s.label)],
      selected: _statusFilter,
    );
    if (result != null) setState(() => _statusFilter = result.value);
  }

  Future<void> _openAssigneeSheet() async {
    List<Member> members;
    try {
      members = await _memberRepository.fetchAll();
    } catch (_) {
      members = [];
    }
    if (!mounted) return;
    final result = await showAppSheet<MemberPick>(
      context,
      isScrollControlled: true,
      builder: (_) => MemberPickerSheet(
        title: 'Filter by assignee',
        allLabel: 'All members',
        members: members,
        selected: _assigneeFilter,
      ),
    );
    if (result != null) setState(() => _assigneeFilter = result.name);
  }

  Future<_FilterChoice<T>?> _showFilterSheet<T>({
    required String title,
    required String allLabel,
    required List<(T, String)> options,
    required T? selected,
  }) {
    return showAppSheet<_FilterChoice<T>>(
      context,
      builder: (context) {
        Widget row(String label, T? value) {
          final isSelected = value == selected;
          return InkWell(
            onTap: () => Navigator.of(context).pop(_FilterChoice<T>(value)),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.cardGap),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.hairline)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: isSelected ? AppColors.primary : AppColors.ink,
                      ),
                    ),
                  ),
                  if (isSelected)
                    const Icon(Icons.check, color: AppColors.primary),
                ],
              ),
            ),
          );
        }

        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screen,
              0,
              AppSpacing.screen,
              AppSpacing.screen,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                row(allLabel, null),
                for (final (value, label) in options) row(label, value),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return EmptyState(icon: Icons.error_outline, message: _error!);
    }

    final tasks = _visibleTasks;
    if (tasks.isEmpty) {
      return EmptyState(icon: Icons.task_alt_outlined, message: _emptyMessage);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${tasks.length} ${tasks.length == 1 ? 'task' : 'tasks'}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: AppSpacing.sm),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.only(bottom: AppSpacing.screen),
            itemCount: tasks.length,
            separatorBuilder: (_, _) =>
                const SizedBox(height: AppSpacing.listGap),
            itemBuilder: (context, index) {
              final task = tasks[index];
              return TaskCard(task: task, onTap: () => _openDetails(task));
            },
          ),
        ),
      ],
    );
  }
}
