import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/page_scaffold.dart';
import 'data/task_repository.dart';
import 'models/task.dart';
import 'screens/create_edit_task_screen.dart';
import 'widgets/task_card.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final _repository = TaskRepository();
  final _searchController = TextEditingController();

  List<Task> _tasks = [];
  SlaStatus? _filter; // null means "All"
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

  /// Reads every task from SQLite and refreshes the screen.
  Future<void> _loadTasks() async {
    try {
      final tasks = await _repository.getAll();
      if (!mounted) return;
      setState(() {
        _tasks = tasks;
        _loading = false;
        _error = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Could not load tasks.';
      });
    }
  }

  /// Opens the form (create when [task] is null, edit otherwise) and reloads
  /// the list if the form reports that something was saved.
  Future<void> _openForm([Task? task]) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => CreateEditTaskScreen(task: task)),
    );
    if (saved == true) _loadTasks();
  }

  /// Tasks after applying the SLA filter and the search text.
  List<Task> get _visibleTasks {
    final q = _query.trim().toLowerCase();
    return _tasks.where((t) {
      final matchesFilter = _filter == null || t.sla == _filter;
      final matchesQuery =
          q.isEmpty ||
          t.title.toLowerCase().contains(q) ||
          t.assignee.toLowerCase().contains(q);
      return matchesFilter && matchesQuery;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: 'Tasks',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSearchRow(),
          const SizedBox(height: AppSpacing.md),
          _buildFilters(),
          const SizedBox(height: AppSpacing.md),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildSearchRow() {
    OutlineInputBorder border(Color color) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.field),
      borderSide: BorderSide(color: color, width: 1.5),
    );

    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchController,
            onChanged: (value) => setState(() => _query = value),
            decoration: InputDecoration(
              hintText: 'Search tasks...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: AppColors.surface,
              contentPadding: const EdgeInsets.symmetric(
                vertical: AppSpacing.md,
              ),
              enabledBorder: border(AppColors.border),
              focusedBorder: border(AppColors.primary),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        FilledButton.icon(
          onPressed: () => _openForm(),
          icon: const Icon(Icons.add),
          label: const Text('Add Task'),
          style: FilledButton.styleFrom(
            minimumSize: const Size(0, 52),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.field),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilters() {
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _filterChip('All', null),
          for (final sla in SlaStatus.values) _filterChip(sla.label, sla),
        ],
      ),
    );
  }

  Widget _filterChip(String label, SlaStatus? value) {
    final selected = _filter == value;
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.sm),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        showCheckmark: false,
        onSelected: (_) => setState(() => _filter = value),
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.primaryTint,
        labelStyle: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: selected ? AppColors.primary : AppColors.ink2,
        ),
        side: BorderSide(
          color: selected ? AppColors.primaryBorder : AppColors.border,
        ),
        shape: const StadiumBorder(),
      ),
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
      return EmptyState(
        icon: Icons.task_alt_outlined,
        message: _tasks.isEmpty
            ? 'No tasks yet.\nTap Add Task to create one.'
            : 'No tasks match your filters.',
      );
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
              // Temporary: opens the edit form until Task Details exists.
              return TaskCard(task: task, onTap: () => _openForm(task));
            },
          ),
        ),
      ],
    );
  }
}
