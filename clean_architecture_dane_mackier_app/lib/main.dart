import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import 'repository/api.dart';
import 'service/authentication_service.dart';
import 'service/interfaces/i_api.dart';
import 'service/posts_service.dart';
import 'ui/router.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Injector(
      inject: [
        //The order doesn't matter.
        Inject<IApi>(() => Api()), // Register with interface
        Inject(() => AuthenticationService(api: Injector.get())),
        Inject(() => PostsService(api: Injector.get())),
      ],
      builder: (context) => MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(),
        initialRoute: 'login',
        onGenerateRoute: Router.generateRoute,
      ),
    );
  }
}
