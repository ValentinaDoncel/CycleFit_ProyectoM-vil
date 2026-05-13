import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cycle_fit/core/services/firebase/firestore_service.dart';
import 'package:cycle_fit/models/app_models.dart';

class FeedFirestoreService {
  const FeedFirestoreService();

  Future<List<FeedPostData>> getPosts({int limit = 50}) async {
    final query = await FirestoreService.feedPostsCollection()
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();

    return query.docs
        .map((doc) => FeedPostData.fromMap(doc.id, doc.data()))
        .toList();
  }

  Future<FeedPostData> createPost(FeedPostData post) async {
    final collection = FirestoreService.feedPostsCollection();
    final document = post.id.isEmpty
        ? collection.doc()
        : collection.doc(post.id);
    final savedPost = FeedPostData(
      id: document.id,
      authorId: post.authorId,
      authorName: post.authorName,
      content: post.content,
      createdAt: post.createdAt,
      imageUrl: post.imageUrl,
      workoutTitle: post.workoutTitle,
      workoutExercises: post.workoutExercises,
      likedBy: post.likedBy,
      commentsCount: post.commentsCount,
    );
    await document.set(savedPost.toMap());
    return savedPost;
  }

  Future<void> toggleLike({
    required String postId,
    required String uid,
    required bool isLiked,
  }) {
    return FirestoreService.feedPostsCollection().doc(postId).update({
      'likedBy': isLiked
          ? FieldValue.arrayRemove([uid])
          : FieldValue.arrayUnion([uid]),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<List<FeedCommentData>> getComments(String postId) async {
    final query = await FirestoreService.feedCommentsCollection(
      postId,
    ).orderBy('createdAt', descending: false).get();

    return query.docs
        .map((doc) => FeedCommentData.fromMap(doc.id, doc.data()))
        .toList();
  }

  Future<void> addComment({
    required String postId,
    required FeedCommentData comment,
  }) async {
    final postRef = FirestoreService.feedPostsCollection().doc(postId);
    final commentRef = FirestoreService.feedCommentsCollection(postId).doc();
    final batch = FirestoreService.instance.batch();
    batch.set(commentRef, comment.toMap());
    batch.update(postRef, {
      'commentsCount': FieldValue.increment(1),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await batch.commit();
  }
}
