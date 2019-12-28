// Copyright 2018 The Flutter Architecture Sample Authors. All rights reserved.
// Use of this source code is governed by the MIT license that can be found
// in the LICENSE file.

import 'package:clean_architecture_todo_app/domain/value_objects/todo_id.dart';
import 'package:clean_architecture_todo_app/service/todo_service.dart';
import 'package:clean_architecture_todo_app/ui/exceptions/todos_error_handler.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import 'add_edit_screen.dart';

class DetailsScreen extends StatelessWidget {
  final TodoID todoID;

  DetailsScreen({@required this.todoID});

  @override
  Widget build(BuildContext context) {
    final todoService = Injector.getAsReactive<TodoService>(context: context);

    final todo = todoService.state.todos
        .firstWhere((todo) => todo.todoID == todoID, orElse: () => null);

    return Scaffold(
      appBar: AppBar(
        title: Text("Todo details"),
        actions: [
          IconButton(
            tooltip: "Delete todo",
            icon: Icon(Icons.delete),
            onPressed: () {
              todoService.setState(
                (state) => state.deleteTodo(todo),
                errorHandler: TodosErrorHandler.errorHandler,
                onSetState: (_) {
                  print(todoService.snapshot);
                  if (todoService.hasData) {
                    Navigator.pop(context, todo);
                  }
                },
              );
            },
          )
        ],
      ),
      body: todo == null
          ? Container()
          : Padding(
              padding: EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(right: 8.0),
                        child: Checkbox(
                          value: todo.complete,
                          onChanged: (_) {
                            todo.complete = !todo.complete;
                            todoService.setState(
                              (state) => state.updateTodo(todo),
                              errorHandler: TodosErrorHandler.errorHandler,
                            );
                          },
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Hero(
                              tag: '${todo.todoID}__heroTag',
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                padding: EdgeInsets.only(
                                  top: 8.0,
                                  bottom: 16.0,
                                ),
                                child: Text(
                                  todo.task,
                                  style: Theme.of(context).textTheme.headline,
                                ),
                              ),
                            ),
                            Text(
                              todo.note,
                              style: Theme.of(context).textTheme.subhead,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        tooltip: "Edit todo",
        child: Icon(Icons.edit),
        heroTag: UniqueKey().toString(),
        onPressed: todo == null
            ? null
            : () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return AddEditScreen(
                        onSave: (task, note) {
                          todo.task = task;
                          todo.note = note;

                          todoService.setState(
                            (state) => state.updateTodo(todo),
                            errorHandler: TodosErrorHandler.errorHandler,
                          );
                        },
                        isEditing: true,
                        todo: todo,
                      );
                    },
                  ),
                );
              },
      ),
    );
  }
}
