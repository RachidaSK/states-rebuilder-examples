import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import '../../../service/posts_service.dart';

class LikeButton extends StatelessWidget {
  final int postId;

  LikeButton({
    @required this.postId,
  });

  @override
  Widget build(BuildContext context) {
    final postsService = Injector.getAsReactive<PostsService>(context: context);

    return Row(
      children: <Widget>[
        Text('Likes ${postsService.state.getPostLikes(postId)}'),
        MaterialButton(
          color: Colors.white,
          child: Icon(Icons.thumb_up),
          onPressed: () {
            postsService.setState((state) => state.incrementLikes(postId));
          },
        )
      ],
    );
  }
}
