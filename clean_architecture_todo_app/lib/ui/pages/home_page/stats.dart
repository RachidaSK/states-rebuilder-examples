// Copyright 2018 The Flutter Architecture Sample Authors. All rights reserved.
// Use of this source code is governed by the MIT license that can be found
// in the LICENSE file.

import 'package:clean_architecture_todo_app/service/todo_service.dart';
import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

class Stats extends StatelessWidget {
  Stats({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final todoService = Injector.getAsReactive<TodoService>(context: context);

    if (todoService.connectionState == ConnectionState.waiting) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    if (todoService.state.todos.isEmpty) {
      return Container();
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 8.0),
            child: Text(
              "Completed todos",
              style: Theme.of(context).textTheme.title,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 24.0),
            child: Text(
              '${todoService.state.numCompleted}',
              style: Theme.of(context).textTheme.subhead,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 8.0),
            child: Text(
              "Active todos",
              style: Theme.of(context).textTheme.title,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 24.0),
            child: Text(
              "${todoService.state.numActive}",
              style: Theme.of(context).textTheme.subhead,
            ),
          )
        ],
      ),
    );
  }
}
