import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import 'repository/file_storage.dart';
import 'repository/todos_repository.dart';
import 'service/todo_service.dart';
import 'ui/pages/home_page/home_page.dart';
import 'ui/utils/enums.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Weather',
      home: Injector(
        inject: [
          Inject(
            () => TodoService(
              TodosRepository(
                fileStorage: FileStorage("__flutter_states_rebuilder__",
                    getApplicationDocumentsDirectory),
              ),
            ),
            initialCustomStateStatus: AppTab.todos,
          ),
        ],
        builder: (_) => HomePage(),
      ),
    );
  }
}
