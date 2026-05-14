import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cycle_fit/core/services/firebase/firestore_service.dart';
import 'package:cycle_fit/models/app_models.dart';

class FeedFirestoreService {
  const FeedFirestoreService();

  Future<List<FeedPostData>> getPosts({int limit = 20}) async {
    final query = await FirestoreService.feedPostsCollection()
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();

    return query.docs
        .map((doc) => FeedPostData.fromMap(doc.id, doc.data()))
        .toList();
  }

  Future<void> createPost(FeedPostData post) async {
    await FirestoreService.feedPostsCollection().add(post.toMap());
  }

  Future<void> toggleLike({
    required String postId,
    required String uid,
    required bool isLiked,
  }) async {
    await FirestoreService.feedPostsCollection().doc(postId).set({
      'likeUids': isLiked
          ? FieldValue.arrayRemove([uid])
          : FieldValue.arrayUnion([uid]),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
