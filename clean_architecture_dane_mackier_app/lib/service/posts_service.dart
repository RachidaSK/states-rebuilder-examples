import '../domain/entities/post.dart';
import 'interfaces/i_api.dart';

class PostsService {
  PostsService({IApi api}) : _api = api;
  IApi _api;
  List<Post> _posts;
  List<Post> get posts => _posts;

  Future<void> getPostsForUser(int userId) async {
    _posts = await _api.getPostsForUser(userId);
  }

  void incrementLikes(int postId) {
    _posts.firstWhere((post) => post.id == postId).incrementLikes();
  }

  int getPostLikes(postId) {
    return _posts.firstWhere((post) => post.id == postId).likes;
  }
}
