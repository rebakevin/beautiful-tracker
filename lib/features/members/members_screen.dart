import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../data/repositories/member_repository.dart';
import '../tasks/data/task_repository.dart';
import '../tasks/models/task.dart' show SlaStatus, Task;
import 'add_member_screen.dart';
import 'member.dart';
import 'member_details_screen.dart';
import 'widgets/member_card.dart';

class MembersScreen extends StatefulWidget {
  const MembersScreen({super.key});

  @override
  State<MembersScreen> createState() => MembersScreenState();
}

class MembersScreenState extends State<MembersScreen> {
  final _repository = const MemberRepository();
  final _taskRepository = TaskRepository();
  List<Member> _members = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    reload();
  }

  /// Refreshes the member list and each member's task count. Exposed so the
  /// shell can reload it when the Members tab is (re)selected.
  Future<void> reload() async {
    try {
      final members = await _repository.fetchAll();
      final tasks = await _taskRepository.getAll();
      final byAssignee = <String, List<Task>>{};
      for (final task in tasks) {
        byAssignee.putIfAbsent(task.assignee, () => []).add(task);
      }
      if (!mounted) return;
      setState(() {
        _members = [
          for (final member in members)
            member.copyWith(
              taskCount: byAssignee[member.name]?.length ?? 0,
              statuses: _statusCounts(byAssignee[member.name] ?? const []),
            ),
        ];
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      debugPrint('Failed to load members: $error');
      setState(() => _loading = false);
    }
  }

  List<TaskStatusCount> _statusCounts(List<Task> tasks) {
    int countOf(bool Function(Task) matches) =>
        tasks.where(matches).length;
    final result = <TaskStatusCount>[];
    for (final status in TaskStatus.values) {
      final count = switch (status) {
        TaskStatus.overdue => countOf((t) => t.sla == SlaStatus.overdue),
        TaskStatus.atRisk => countOf((t) => t.sla == SlaStatus.atRisk),
        TaskStatus.onTrack => countOf((t) => t.sla == SlaStatus.onTrack),
        TaskStatus.done => countOf((t) => t.sla == SlaStatus.completed),
      };
      if (count > 0) result.add(TaskStatusCount(status, count));
    }
    return result;
  }

  Future<void> _openAddMember() async {
    final added = await Navigator.of(context).push<Member>(
      MaterialPageRoute<Member>(builder: (_) => const AddMemberScreen()),
    );
    if (added != null) {
      await reload();
    }
  }

  Future<void> _openMemberDetails(Member member) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => MemberDetailsScreen(member: member),
      ),
    );
    await reload();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screen,
          AppSpacing.screen,
          AppSpacing.screen,
          0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Header(memberCount: _members.length, onAdd: _openAddMember),
            const SizedBox(height: AppSpacing.section),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_members.isEmpty) {
      return _EmptyMembersState(onAdd: _openAddMember);
    }
    return ListView.separated(
      itemCount: _members.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.listGap),
      itemBuilder: (context, index) {
        final member = _members[index];
        return MemberCard(
          member: member,
          onTap: () => _openMemberDetails(member),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.memberCount, required this.onAdd});

  final int memberCount;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Team Members',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 2),
              Text(
                '$memberCount members',
                style: GoogleFonts.barlow(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.muted,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        FilledButton(
          onPressed: onAdd,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: const StadiumBorder(),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.cardPadding,
              vertical: 12,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.add, size: 18),
              SizedBox(width: 4),
              Text('Add'),
            ],
          ),
        ),
      ],
    );
  }
}

class _EmptyMembersState extends StatelessWidget {
  const _EmptyMembersState({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: AppColors.primaryTint,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.people_outline,
              size: 40,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.section),
          Text('No members yet', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Add your first team member to get started',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.section),
          FilledButton.icon(
            onPressed: onAdd,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.cardPadding,
                vertical: 12,
              ),
            ),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add member'),
          ),
        ],
      ),
    );
  }
}
