import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../widgets/initials_avatar.dart';
import '../../../widgets/option_picker_sheet.dart';
import '../../../widgets/toast.dart';

enum _PhotoAction {
  camera('Take photo'),
  gallery('Choose from library'),
  remove('Remove photo');

  const _PhotoAction(this.label);
  final String label;
}

/// Profile photo with a "Change photo" button. Reports the choice through
/// [onPicked] (a new photo) or [onRemoved]; nothing is saved until the form is.
class AvatarEditor extends StatelessWidget {
  const AvatarEditor({
    super.key,
    required this.initials,
    required this.imagePath,
    required this.onPicked,
    required this.onRemoved,
  });

  final String initials;
  final String? imagePath;
  final ValueChanged<XFile> onPicked;
  final VoidCallback onRemoved;

  Future<void> _change(BuildContext context) async {
    final action = await showOptionPickerSheet<_PhotoAction>(
      context,
      title: 'Profile photo',
      options: [
        for (final a in _PhotoAction.values)
          if (a != _PhotoAction.remove || imagePath != null) (a, a.label),
      ],
    );
    if (action == null || !context.mounted) return;

    if (action == _PhotoAction.remove) return onRemoved();

    try {
      final photo = await ImagePicker().pickImage(
        source: action == _PhotoAction.camera
            ? ImageSource.camera
            : ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      if (photo != null) onPicked(photo);
    } catch (e) {
      debugPrint('Could not pick photo: $e');
      if (context.mounted) {
        showToast(context, 'Could not open the camera or photo library.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InitialsAvatar(initials: initials, imagePath: imagePath, size: 92),
        // Photos are stored as device files, which the web build cannot use.
        if (!kIsWeb) ...[
          const SizedBox(height: AppSpacing.xs),
          TextButton(
            onPressed: () => _change(context),
            child: const Text('Change photo'),
          ),
        ],
      ],
    );
  }
}
