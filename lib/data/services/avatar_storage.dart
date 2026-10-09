import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Keeps profile photos in the app's private documents folder, so they live
/// only on this device. The database stores just the file path.
class AvatarStorage {
  const AvatarStorage();

  static const _folder = 'avatars';

  /// Copies [photo] into app storage and returns the new path. The name
  /// changes on every save so Flutter's image cache never shows a stale photo.
  Future<String> save(XFile photo, {required int userId}) async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(docs.path, _folder));
    await dir.create(recursive: true);
    final ext = p.extension(photo.path).isEmpty
        ? '.jpg'
        : p.extension(photo.path);
    final target = p.join(
      dir.path,
      'user_${userId}_${DateTime.now().millisecondsSinceEpoch}$ext',
    );
    await File(photo.path).copy(target);
    return target;
  }

  Future<void> delete(String? path) async {
    if (path == null) return;
    try {
      final file = File(path);
      if (await file.exists()) await file.delete();
    } catch (_) {}
  }
}
