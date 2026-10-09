import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../data/repositories/member_repository.dart';
import 'add_member_screen.dart';
import 'member.dart';
import 'member_details_screen.dart';
import 'widgets/member_card.dart';

class MembersScreen extends StatefulWidget {
  const MembersScreen({super.key});

  @override
  State<MembersScreen> createState() => _MembersScreenState();
}

class _MembersScreenState extends State<MembersScreen> {
  final _repository = const MemberRepository();
  List<Member> _members = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final members = await _repository.fetchAll();
      if (!mounted) return;
      setState(() {
        _members = members;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      debugPrint('Failed to load members: $error');
      setState(() => _loading = false);
    }
  }

  Future<void> _openAddMember() async {
    final added = await Navigator.of(context).push<Member>(
      MaterialPageRoute<Member>(builder: (_) => const AddMemberScreen()),
    );
    if (added != null) {
      await _load();
    }
  }

  Future<void> _openMemberDetails(Member member) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => MemberDetailsScreen(member: member),
      ),
    );
    await _load();
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
