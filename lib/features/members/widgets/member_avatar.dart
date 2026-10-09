import 'package:flutter/material.dart';

import '../../../core/session/session_scope.dart';
import '../../../core/theme/app_colors.dart';
import '../../../widgets/initials_avatar.dart';

class MemberAvatar extends StatelessWidget {
  const MemberAvatar({
    super.key,
    required this.initials,
    this.email,
    this.size = 48,
  });

  final String initials;

  /// The member's email. When it is the signed-in user's, their profile photo
  /// is shown (photos are only stored for the signed-in user's own account).
  final String? email;
  final double size;

  @override
  Widget build(BuildContext context) {
    final user = SessionScope.of(context).user;
    final isMe =
        email != null &&
        user != null &&
        email!.trim().toLowerCase() == user.email.trim().toLowerCase();

    return InitialsAvatar(
      initials: initials,
      imagePath: isMe ? user.avatarPath : null,
      size: size,
      background: AppColors.yellow200,
      foreground: AppColors.brownInk,
    );
  }
}
