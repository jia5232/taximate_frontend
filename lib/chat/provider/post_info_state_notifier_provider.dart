import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../post/model/post_model.dart';

final postInfoProvider = StateNotifierProvider<PostNotifier, PostModel?>((ref) => PostNotifier());

class PostNotifier extends StateNotifier<PostModel?> {
  PostNotifier() : super(null);

  void setPost(PostModel post) {
    state = post;
  }
}