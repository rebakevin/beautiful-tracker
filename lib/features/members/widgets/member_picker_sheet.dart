import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../member.dart' show Member;

/// Result of [MemberPickerSheet]; [name] is null when "All" was picked.
class MemberPick {
  const MemberPick(this.name);
  final String? name;
}

class MemberPickerSheet extends StatefulWidget {
  const MemberPickerSheet({
    super.key,
    required this.title,
    required this.members,
    required this.selected,
    this.allLabel,
  });

  final String title;
  final String? allLabel;
  final List<Member> members;
  final String? selected;

  @override
  State<MemberPickerSheet> createState() => _MemberPickerSheetState();
}

class _MemberPickerSheetState extends State<MemberPickerSheet> {
  static const _collapsedCount = 4;
  bool _expanded = false;
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final all = widget.members;
    final canCollapse = all.length > _collapsedCount;
    final q = _query.trim().toLowerCase();
    final shown = !canCollapse
        ? all
        : !_expanded
        ? all.take(_collapsedCount).toList()
        : all
              .where(
                (m) =>
                    q.isEmpty ||
                    m.name.toLowerCase().contains(q) ||
                    m.email.toLowerCase().contains(q),
              )
              .toList();

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.8,
        ),
        child: Padding(
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
                  widget.title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              if (_expanded) ...[
                TextField(
                  autofocus: true,
                  onChanged: (v) => setState(() => _query = v),
                  decoration: InputDecoration(
                    hintText: 'Search members',
                    prefixIcon: const Icon(Icons.search),
                    isDense: true,
                    filled: true,
                    fillColor: AppColors.ground,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.md,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.field),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.field),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.field),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
              if (all.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.section),
                  child: Text(
                    'No members yet. Add members in the Members tab.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.muted),
                  ),
                )
              else
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      if (widget.allLabel != null) _allRow(),
                      for (final m in shown) _memberRow(m),
                      if (_expanded && shown.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: AppSpacing.section,
                          ),
                          child: Text(
                            'No members match your search.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.muted),
                          ),
                        ),
                      if (canCollapse && !_expanded) _toggleRow(all.length),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _allRow() {
    final isSelected = widget.selected == null;
    return InkWell(
      onTap: () => Navigator.of(context).pop(const MemberPick(null)),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.cardGap),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.hairline)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                widget.allLabel!,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? AppColors.primary : AppColors.ink,
                ),
              ),
            ),
            if (isSelected) const Icon(Icons.check, color: AppColors.primary),
          ],
        ),
      ),
    );
  }

  Widget _memberRow(Member m) {
    final isSelected = m.name == widget.selected;
    return InkWell(
      onTap: () => Navigator.of(context).pop(MemberPick(m.name)),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.hairline)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    m.name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: isSelected ? AppColors.primary : AppColors.ink,
                    ),
                  ),
                  Text(
                    m.email,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected) const Icon(Icons.check, color: AppColors.primary),
          ],
        ),
      ),
    );
  }

  Widget _toggleRow(int total) {
    return InkWell(
      onTap: () => setState(() => _expanded = !_expanded),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.cardGap),
        child: Row(
          children: [
            Expanded(
              child: Text(
                _expanded
                    ? 'Show fewer members'
                    : 'Show all $total members (+${total - _collapsedCount} more)',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
            Icon(
              _expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}
