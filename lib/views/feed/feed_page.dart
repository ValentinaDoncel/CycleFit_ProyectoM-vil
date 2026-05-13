import 'package:cycle_fit/controllers/app_controller.dart';
import 'package:cycle_fit/core/theme/app_colors.dart';
import 'package:cycle_fit/core/utils/responsive.dart';
import 'package:cycle_fit/models/app_models.dart';
import 'package:cycle_fit/widgets/surface_card.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class FeedPage extends StatelessWidget {
  const FeedPage({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final horizontal = context.pageHorizontalPadding;
    return RefreshIndicator(
      onRefresh: controller.refreshFeed,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(horizontal, 20, horizontal, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Feed Cyclofit',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Comparte tu progreso con la comunidad',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.muted,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 20),
            SurfaceCard(
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => _showCreatePostDialog(context),
                child: Row(
                  children: [
                    const _AvatarCircle(label: 'CF'),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Como te sientes hoy?',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    const Icon(
                      Icons.photo_library_outlined,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (controller.isLoadingFeed)
              const Center(child: CircularProgressIndicator())
            else if (controller.posts.isEmpty)
              const SurfaceCard(child: Text('Aun no hay publicaciones.'))
            else
              for (final post in controller.posts) ...[
                _PostCard(
                  post: post,
                  onLike: () => controller.toggleFeedLike(post),
                  onComments: () => _showCommentsDialog(context, post),
                  onWorkoutTap: () => controller.useFeedWorkout(post),
                ),
                const SizedBox(height: 16),
              ],
          ],
        ),
      ),
    );
  }

  Future<void> _showCreatePostDialog(BuildContext context) async {
    final textController = TextEditingController();
    XFile? selectedImage;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Nueva publicacion'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: textController,
                minLines: 3,
                maxLines: 5,
                decoration: const InputDecoration(labelText: 'Mensaje'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () async {
                  final image = await ImagePicker().pickImage(
                    source: ImageSource.gallery,
                    imageQuality: 60,
                    maxWidth: 1200,
                  );
                  if (image != null) setState(() => selectedImage = image);
                },
                icon: const Icon(Icons.photo_library_outlined),
                label: Text(
                  selectedImage == null ? 'Agregar foto' : selectedImage!.name,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: controller.isSavingPost
                  ? null
                  : () async {
                      await controller.createFeedPost(
                        content: textController.text,
                        image: selectedImage,
                      );
                      if (dialogContext.mounted) {
                        Navigator.of(dialogContext).pop();
                      }
                    },
              child: const Text('Publicar'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showCommentsDialog(BuildContext context, PostModel post) async {
    final commentController = TextEditingController();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.fromLTRB(
          18,
          18,
          18,
          MediaQuery.of(sheetContext).viewInsets.bottom + 18,
        ),
        child: FutureBuilder<List<FeedCommentData>>(
          future: controller.getFeedComments(post.id),
          builder: (context, snapshot) {
            final comments = snapshot.data ?? const <FeedCommentData>[];
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Comentarios',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                if (comments.isEmpty)
                  const Text('Sin comentarios todavia.')
                else
                  ...comments.map(
                    (comment) => ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text(comment.authorName),
                      subtitle: Text(comment.content),
                    ),
                  ),
                TextField(
                  controller: commentController,
                  decoration: const InputDecoration(
                    labelText: 'Escribe un comentario',
                  ),
                ),
                const SizedBox(height: 10),
                FilledButton(
                  onPressed: () async {
                    await controller.addFeedComment(
                      postId: post.id,
                      content: commentController.text,
                    );
                    if (sheetContext.mounted) Navigator.of(sheetContext).pop();
                  },
                  child: const Text('Comentar'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  const _PostCard({
    required this.post,
    required this.onLike,
    required this.onComments,
    required this.onWorkoutTap,
  });

  final PostModel post;
  final VoidCallback onLike;
  final VoidCallback onComments;
  final VoidCallback onWorkoutTap;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _AvatarCircle(label: post.avatar),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.author,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      post.timeAgo,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(post.content, style: Theme.of(context).textTheme.bodyLarge),
          if (post.imageUrl != null) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                post.imageUrl!,
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ],
          if (post.workoutTitle != null) ...[
            const SizedBox(height: 12),
            InkWell(
              onTap: onWorkoutTap,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F3ED),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.workoutTitle!,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 6),
                    Text(post.workoutExercises.join(' - ')),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              TextButton.icon(
                onPressed: onLike,
                icon: Icon(
                  post.isLikedByCurrentUser
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                ),
                label: Text('${post.likes}'),
              ),
              TextButton.icon(
                onPressed: onComments,
                icon: const Icon(Icons.mode_comment_outlined),
                label: Text('${post.comments}'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AvatarCircle extends StatelessWidget {
  const _AvatarCircle({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: const Color(0xFFF0ECE6),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
