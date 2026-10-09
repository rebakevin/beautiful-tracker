import 'package:flutter/material.dart';

import '../../core/session/session_scope.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/app_spacing.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/initials_avatar.dart';
import '../../widgets/page_scaffold.dart';
import 'change_password_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _confirmSignOut(BuildContext context) async {
    final controller = SessionScope.controllerOf(context);
    final confirmed = await showConfirmDialog(
      context,
      title: 'Sign out?',
      message: 'You will return to the sign-in screen.',
      confirmLabel: 'Sign Out',
    );
    if (confirmed) await controller.signOut();
  }

  void _open(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    // Depending on SessionScope rebuilds this screen when the profile or
    // dark mode changes.
    final session = SessionScope.of(context);
    final user = session.user!;
    final text = Theme.of(context).textTheme;

    return PageScaffold(
      title: 'Profile',
      child: ListView(
        padding: const EdgeInsets.only(bottom: AppSpacing.section),
        children: [
          Column(
            children: [
              InitialsAvatar(initials: user.initials, size: 92),
              const SizedBox(height: 16),
              Text(
                user.name,
                textAlign: TextAlign.center,
                style: text.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                user.email,
                textAlign: TextAlign.center,
                style: text.bodyLarge?.copyWith(color: context.palette.muted),
              ),
            ],
          ),
          const SizedBox(height: 36),
          _SettingsCard(
            children: [
              _SettingsRow(
                label: 'Edit Profile',
                trailing: const _Chevron(),
                onTap: () => _open(context, const EditProfileScreen()),
              ),
              _SettingsRow(
                label: 'Change Password',
                trailing: const _Chevron(),
                onTap: () => _open(context, const ChangePasswordScreen()),
              ),
              _SettingsRow(
                label: 'Dark mode',
                trailing: Switch(
                  value: session.darkMode,
                  onChanged: session.controller.setDarkMode,
                ),
                onTap: () => session.controller.setDarkMode(!session.darkMode),
              ),
              _SettingsRow(
                label: 'Sign Out',
                labelColor: AppColors.danger,
                onTap: () => _confirmSignOut(context),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (final (i, child) in children.indexed) ...[
            if (i > 0) const Divider(),
            child,
          ],
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.label,
    required this.onTap,
    this.trailing,
    this.labelColor,
  });

  final String label;
  final VoidCallback onTap;
  final Widget? trailing;
  final Color? labelColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      highlightColor: context.palette.wash,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 60),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: labelColor,
                  ),
                ),
              ),
              ?trailing,
            ],
          ),
        ),
      ),
    );
  }
}

class _Chevron extends StatelessWidget {
  const _Chevron();

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.chevron_right_rounded,
      size: 22,
      color: context.palette.muted,
    );
  }
}
