import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class FeedStorageService {
  const FeedStorageService();

  Future<String> uploadPostImage({
    required String uid,
    required XFile image,
  }) async {
    final bytes = await image.readAsBytes();
    final extension = image.name.split('.').last.toLowerCase();
    final safeExtension = extension.length > 5 ? 'jpg' : extension;
    final ref = FirebaseStorage.instance
        .ref()
        .child('feed_posts')
        .child(uid)
        .child('${DateTime.now().millisecondsSinceEpoch}.$safeExtension');

    final metadata = SettableMetadata(
      contentType: image.mimeType ?? 'image/jpeg',
    );
    await ref.putData(bytes, metadata);
    return ref.getDownloadURL();
  }
}
