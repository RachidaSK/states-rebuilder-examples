import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import '../../../domain/entities/todo_entity.dart';
import '../../../service/todo_service.dart';
import '../../exceptions/todos_error_handler.dart';
import '../../utils/enums.dart';
import '../add_edit_screen.dart';
import 'extra_actions.dart';
import 'filter_button.dart';
import 'filtered_todos.dart';
import 'stats.dart';
import 'tab_selector.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final todoService = Injector.getAsReactive<TodoService>();

    return StateBuilder(
      models: [todoService],
      builderWithChild: (context, snapshot, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text("Todo App"),
            actions: [
              FilterButton(
                  visible: todoService.customStateStatus == AppTab.todos),
              ExtraActions(),
            ],
          ),
          body: StateBuilder(
            models: [todoService],
            tag: "FilteredTodos",
            afterInitialBuild: (_, __) {
              todoService.setState(
                (state) => state.loadTodos(),
                errorHandler: TodosErrorHandler.errorHandler,
              );
            },
            builder: (_, __) => todoService.customStateStatus == AppTab.todos
                ? FilteredTodos()
                : Stats(),
          ),
          floatingActionButton: child,
          bottomNavigationBar: TabSelector(
            activeTab: todoService.customStateStatus,
            onTabSelected: (tab) => todoService.setState(
              (_) => todoService.customStateStatus = tab,
            ),
          ),
        );
      },
      child: FloatingActionButton(
        key: UniqueKey(),
        heroTag: UniqueKey().toString(),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddEditScreen(
                onSave: (task, note) {
                  todoService.setState(
                    (state) => state.addTodo(
                      TodoEntity(task, null, note, false),
                    ),
                    errorHandler: TodosErrorHandler.errorHandler,
                  );
                },
                isEditing: false,
              ),
            ),
          );
        },
        child: Icon(Icons.add),
        tooltip: "Add todo",
      ),
    );
  }
}
