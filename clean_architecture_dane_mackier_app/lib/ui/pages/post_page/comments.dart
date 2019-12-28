import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import '../../../domain/entities/comment.dart';
import '../../../service/comments_service.dart';
import '../../exceptions/error_handler.dart';
import '../../utils/app_colors.dart';
import '../../utils/ui_helpers.dart';

class Comments extends StatelessWidget {
  final int postId;
  Comments(this.postId);

  @override
  Widget build(BuildContext context) {
    return Injector(
      inject: [Inject(() => CommentsService(api: Injector.get()))],
      builder: (context) {
        final commentsService = Injector.getAsReactive<CommentsService>();

        return StateBuilder(
          models: [commentsService],
          afterInitialBuild: (_, __) => commentsService.setState(
            (state) => state.fetchComments(postId),
            errorHandler: ErrorHandler.showErrorDialog,
          ),
          builder: (_, __) {
            if (commentsService.hasData) {
              return Expanded(
                child: ListView(
                  children: commentsService.state.comments
                      .map((comment) => CommentItem(comment))
                      .toList(),
                ),
              );
            }

            return Center(child: CircularProgressIndicator());
          },
        );
      },
    );
  }
}

/// Renders a single comment given a comment model
class CommentItem extends StatelessWidget {
  final Comment comment;
  const CommentItem(this.comment);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10.0),
      margin: EdgeInsets.symmetric(vertical: 10.0),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0), color: commentColor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            comment.name,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          UIHelper.verticalSpaceSmall(),
          Text(comment.body),
        ],
      ),
    );
  }
}
