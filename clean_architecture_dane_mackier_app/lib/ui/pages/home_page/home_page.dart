import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import '../../../domain/entities/post.dart';
import '../../../service/authentication_service.dart';
import '../../../service/posts_service.dart';
import '../../exceptions/error_handler.dart';
import '../../utils/app_colors.dart';
import '../../utils/text_styles.dart';
import '../../utils/ui_helpers.dart';
import 'postlist_item.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final postsService = Injector.getAsReactive<PostsService>();
    final user = Injector.get<AuthenticationService>().user;
    return Scaffold(
      backgroundColor: backgroundColor,
      body: StateBuilder(
        models: [postsService],
        initState: (_, __) => postsService.setState(
          (state) => state.getPostsForUser(user.id),
          errorHandler: ErrorHandler.showErrorDialog,
        ),
        builder: (context, _) {
          if (postsService.connectionState == ConnectionState.none) {
            return Center(
                child: Text('Something seems to not work ${user.name}'));
          }

          if (postsService.isWaiting) {
            return Center(child: CircularProgressIndicator());
          }

          return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                UIHelper.verticalSpaceLarge(),
                Padding(
                  padding: const EdgeInsets.only(left: 20.0),
                  child: Text(
                    'Welcome ${user.name}',
                    style: headerStyle,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20.0),
                  child: Text('Here are all your posts', style: subHeaderStyle),
                ),
                UIHelper.verticalSpaceSmall(),
                Expanded(child: Builder(builder: (context) {
                  return getPostsUi(postsService.state.posts);
                })),
              ]);
        },
      ),
    );
  }

  Widget getPostsUi(List<Post> posts) => ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) => PostListItem(
          post: posts[index],
          onTap: () {
            Navigator.pushNamed(context, 'post', arguments: posts[index]);
          },
        ),
      );
}
