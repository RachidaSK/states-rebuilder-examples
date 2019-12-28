import '../domain/entities/comment.dart';
import 'interfaces/i_api.dart';

class CommentsService {
  IApi _api;
  CommentsService({IApi api}) : _api = api;

  List<Comment> comments;

  Future<void> fetchComments(int postId) async {
    comments = await _api.getCommentsForPost(postId);
  }
}
