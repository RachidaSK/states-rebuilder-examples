import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import '../../../domain/entities/post.dart';
import '../../../service/authentication_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/text_styles.dart';
import '../../utils/ui_helpers.dart';
import 'comments.dart';
import 'like_button.dart';

class PostPage extends StatelessWidget {
  final Post post;
  PostPage({this.post});

  @override
  Widget build(BuildContext context) {
    final user = Injector.get<AuthenticationService>().user;
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            UIHelper.verticalSpaceLarge(),
            Text(post.title, style: headerStyle),
            Text(
              'by ${user.name}',
              style: TextStyle(fontSize: 9.0),
            ),
            UIHelper.verticalSpaceMedium(),
            Text(post.body),
            LikeButton(
              postId: post.id,
            ),
            Comments(post.id)
          ],
        ),
      ),
    );
  }
}
