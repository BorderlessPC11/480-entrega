import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

String _imageContentType(String fileName) {
  final n = fileName.toLowerCase();
  if (n.endsWith('.png')) return 'image/png';
  if (n.endsWith('.webp')) return 'image/webp';
  if (n.endsWith('.gif')) return 'image/gif';
  if (n.endsWith('.heic') || n.endsWith('.heif')) return 'image/heic';
  return 'image/jpeg';
}

/// Envia a foto de perfil para o Storage em `profile_photos/{uid}/avatar.jpg`.
class ProfilePhotoStorage {
  ProfilePhotoStorage({FirebaseStorage? storage})
      : _storage = storage ?? FirebaseStorage.instance;

  final FirebaseStorage _storage;

  Reference _ref(String uid) =>
      _storage.ref('profile_photos').child(uid).child('avatar.jpg');

  Future<String> uploadProfilePhoto(String uid, XFile file) async {
    final bytes = await file.readAsBytes();
    final name = file.name;
    final type = file.mimeType ?? _imageContentType(name);
    await _ref(uid).putData(
      bytes,
      SettableMetadata(
        contentType: type,
        customMetadata: <String, String>{'uid': uid},
      ),
    );
    return _ref(uid).getDownloadURL();
  }

  /// Apaga a foto no nosso path (ignorado se não existir, ex. só avatar Google).
  Future<void> deleteProfilePhoto(String uid) async {
    try {
      await _ref(uid).delete();
    } on FirebaseException catch (e) {
      if (e.code == 'object-not-found') {
        return;
      }
      rethrow;
    }
  }
}
