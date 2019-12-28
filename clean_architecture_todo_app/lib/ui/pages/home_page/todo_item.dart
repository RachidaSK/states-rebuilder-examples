// Copyright 2018 The Flutter Architecture Sample Authors. All rights reserved.
// Use of this source code is governed by the MIT license that can be found
// in the LICENSE file.

import 'package:clean_architecture_todo_app/domain/entities/todo_entity.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class TodoItem extends StatelessWidget {
  final DismissDirectionCallback onDismissed;
  final GestureTapCallback onTap;
  final ValueChanged<bool> onCheckboxChanged;
  final TodoEntity todo;

  TodoItem({
    Key key,
    @required this.onDismissed,
    @required this.onTap,
    @required this.onCheckboxChanged,
    @required this.todo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: UniqueKey(),
      onDismissed: onDismissed,
      child: ListTile(
        onTap: onTap,
        leading: Checkbox(
          value: todo.complete,
          onChanged: onCheckboxChanged,
        ),
        title: Hero(
          tag: '${todo.todoID}__heroTag',
          child: Container(
            width: MediaQuery.of(context).size.width,
            child: Text(
              todo.task,
              style: Theme.of(context).textTheme.title,
            ),
          ),
        ),
        subtitle: todo.note.isNotEmpty
            ? Text(
                todo.note,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.subhead,
              )
            : null,
      ),
    );
  }
}
