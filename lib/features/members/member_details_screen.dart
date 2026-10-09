import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../data/repositories/member_repository.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/screen_top_bar.dart';
import '../tasks/data/task_repository.dart';
import '../tasks/models/task.dart';
import '../tasks/screens/task_details_screen.dart';
import '../tasks/widgets/task_card.dart';
import 'add_member_screen.dart';
import 'member.dart' show Member;
import 'widgets/member_avatar.dart';

const _dangerOutline = Color(0xFFF3BDB9);

class MemberDetailsScreen extends StatefulWidget {
  const MemberDetailsScreen({super.key, required this.member});

  final Member member;

  @override
  State<MemberDetailsScreen> createState() => _MemberDetailsScreenState();
}

class _MemberDetailsScreenState extends State<MemberDetailsScreen> {
  final _repository = const MemberRepository();
  final _taskRepository = TaskRepository();
  late Member _member;
  List<Task> _tasks = [];
  bool _loadingTasks = true;

  @override
  void initState() {
    super.initState();
    _member = widget.member;
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    try {
      final tasks = await _taskRepository.getAll();
      if (!mounted) return;
      setState(() {
        _tasks = tasks
            .where((task) => task.assignee == _member.name)
            .toList();
        _loadingTasks = false;
      });
    } catch (error) {
      if (!mounted) return;
      debugPrint('Failed to load tasks: $error');
      setState(() => _loadingTasks = false);
    }
  }

  Future<void> _openTaskDetails(Task task) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(builder: (_) => TaskDetailsScreen(task: task)),
    );
    if (changed == true) await _loadTasks();
  }

  Widget _buildAssignedTasks() {
    if (_loadingTasks) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.section),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_tasks.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.section),
        child: EmptyState(
          icon: Icons.task_alt_outlined,
          message: 'No assigned tasks yet',
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final task in _tasks)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.listGap),
            child: TaskCard(task: task, onTap: () => _openTaskDetails(task)),
          ),
      ],
    );
  }

  Future<void> _editMember() async {
    final updated = await Navigator.of(context).push<Member>(
      MaterialPageRoute<Member>(
        builder: (_) => AddMemberScreen(member: _member),
      ),
    );
    if (updated != null && mounted) {
      setState(() => _member = updated);
    }
  }

  Future<void> _confirmRemove() async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Remove member',
      message: 'Remove ${_member.name} from the team?',
      confirmLabel: 'Remove',
      destructive: true,
    );
    if (!confirmed || !mounted) return;

    try {
      await _repository.delete(_member.id!);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not remove the member.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ground,
      body: SafeArea(
        child: Column(
          children: [
            const ScreenTopBar(title: 'Member'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screen,
                  AppSpacing.section,
                  AppSpacing.screen,
                  0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _ProfileHeader(member: _member),
                    const SizedBox(height: AppSpacing.section),
                    _StatsRow(
                      assigned: _tasks.length,
                      completed: _tasks
                          .where((t) => t.status == TaskStatus.completed)
                          .length,
                      overdue: _tasks
                          .where((t) => t.sla == SlaStatus.overdue)
                          .length,
                    ),
                    const SizedBox(height: AppSpacing.section),
                    _ActionRow(onEdit: _editMember, onRemove: _confirmRemove),
                    const SizedBox(height: AppSpacing.section),
                    Text(
                      'Assigned Tasks',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _buildAssignedTasks(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.member});

  final Member member;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        MemberAvatar(initials: member.initials, email: member.email, size: 42),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                member.name,
                style: GoogleFonts.barlow(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                member.email,
                style: GoogleFonts.barlow(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.muted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({
    required this.assigned,
    required this.completed,
    required this.overdue,
  });

  final int assigned;
  final int completed;
  final int overdue;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(value: '$assigned', label: 'Assigned'),
        ),
        const SizedBox(width: AppSpacing.cardGap),
        Expanded(
          child: _StatCard(value: '$completed', label: 'Completed'),
        ),
        const SizedBox(width: AppSpacing.cardGap),
        Expanded(
          child: _StatCard(
            value: '$overdue',
            label: 'Overdue',
            valueColor: AppColors.overdueFg,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.value,
    required this.label,
    this.valueColor = AppColors.ink,
  });

  final String value;
  final String label;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: GoogleFonts.barlow(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: valueColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.barlow(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: AppColors.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({required this.onEdit, required this.onRemove});

  final VoidCallback onEdit;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 52,
            child: OutlinedButton(
              onPressed: onEdit,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.ink,
                backgroundColor: AppColors.surface,
                side: const BorderSide(color: AppColors.hairline),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.field),
                ),
                textStyle: GoogleFonts.barlow(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: const Text('Edit Member'),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.cardGap),
        Expanded(
          child: SizedBox(
            height: 52,
            child: OutlinedButton(
              onPressed: onRemove,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.danger,
                backgroundColor: AppColors.surface,
                side: const BorderSide(color: _dangerOutline),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.field),
                ),
                textStyle: GoogleFonts.barlow(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: const Text('Remove'),
            ),
          ),
        ),
      ],
    );
  }
}
