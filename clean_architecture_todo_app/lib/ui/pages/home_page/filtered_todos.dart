// Copyright 2018 The Flutter Architecture Sample Authors. All rights reserved.
// Use of this source code is governed by the MIT license that can be found
// in the LICENSE file.

import 'package:clean_architecture_todo_app/service/todo_service.dart';
import 'package:clean_architecture_todo_app/ui/exceptions/todos_error_handler.dart';
import 'package:clean_architecture_todo_app/ui/pages/home_page/todo_item.dart';
import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import '../details_screen.dart';
import 'delete_todo_snackbar.dart';

class FilteredTodos extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final todoService = Injector.getAsReactive<TodoService>();

    if (todoService.connectionState == ConnectionState.waiting) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    if (todoService.hasError) {
      return Center(
        child: RaisedButton(
          child: Text('Tap here to refresh'),
          onPressed: () {
            todoService.setState(
              (state) => state.loadTodos(),
              errorHandler: TodosErrorHandler.errorHandler,
            );
          },
        ),
      );
    }

    if (todoService.state.todos.isEmpty) {
      return Container();
    }

    final todos = todoService.state.todos;

    return ListView.builder(
      itemCount: todos.length,
      itemBuilder: (_, int index) {
        final todo = todos[index];
        return TodoItem(
          todo: todo,
          onDismissed: (direction) {
            todoService.setState(
              (state) => state.deleteTodo(todo),
              errorHandler: TodosErrorHandler.errorHandler,
            );

            Scaffold.of(context).showSnackBar(
              DeleteTodoSnackBar(
                todo: todo,
                onUndo: () => todoService.setState(
                  (state) => state.addTodo(todo),
                  errorHandler: TodosErrorHandler.errorHandler,
                ),
              ),
            );
          },
          onTap: () async {
            final removedTodo = await Navigator.of(context).push(
              MaterialPageRoute(builder: (_) {
                // return StateBuilder(
                //     models: [todoService],
                //     builder: (_, __) => DetailsScreen(id: todo.id));
                return Injector(
                    // inject: [Inject(() => todoService.state)],
                    reinject: [todoService],
                    builder: (_) => DetailsScreen(todoID: todo.todoID));
              }),
            );
            print('removedTodo $removedTodo');
            if (removedTodo != null) {
              Scaffold.of(context).showSnackBar(
                DeleteTodoSnackBar(
                  todo: todo,
                  onUndo: () => todoService.setState(
                    (state) => state.addTodo(todo),
                    errorHandler: TodosErrorHandler.errorHandler,
                  ),
                ),
              );
            }
          },
          onCheckboxChanged: (_) {
            todo.complete = !todo.complete;
            todoService.setState(
              (state) => state.updateTodo(todo),
              errorHandler: TodosErrorHandler.errorHandler,
            );
          },
        );
      },
    );
  }
}
