// Copyright 2018 The Flutter Architecture Sample Authors. All rights reserved.
// Use of this source code is governed by the MIT license that can be found
// in the LICENSE file.

import 'package:clean_architecture_todo_app/service/todo_service.dart';
import 'package:clean_architecture_todo_app/service/utils/enums.dart';
import 'package:clean_architecture_todo_app/ui/exceptions/todos_error_handler.dart';
import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

class ExtraActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final todoService = Injector.getAsReactive<TodoService>();

    if (todoService.state.todos.isEmpty) {
      return Container();
    }

    bool allComplete = todoService.state.todos.every((todo) => todo.complete);

    return PopupMenuButton<ExtraAction>(
      onSelected: (action) {
        switch (action) {
          case ExtraAction.clearCompleted:
            todoService.setState(
              (state) => state.clearCompletedTodos(),
              errorHandler: TodosErrorHandler.errorHandler,
            );
            break;
          case ExtraAction.toggleAllComplete:
            todoService.setState(
              (state) => state.toggleAll(),
              errorHandler: TodosErrorHandler.errorHandler,
            );

            break;
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuItem<ExtraAction>>[
        PopupMenuItem<ExtraAction>(
          value: ExtraAction.toggleAllComplete,
          child: Text(
            allComplete ? "Mark all incomplete" : "Mark all complete",
          ),
        ),
        PopupMenuItem<ExtraAction>(
          value: ExtraAction.clearCompleted,
          child: Text(
            "clear completed",
          ),
        ),
      ],
    );
  }
}
