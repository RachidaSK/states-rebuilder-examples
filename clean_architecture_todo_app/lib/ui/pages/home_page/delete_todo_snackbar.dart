import 'package:clean_architecture_todo_app/domain/entities/todo_entity.dart';
import 'package:flutter/material.dart';

class DeleteTodoSnackBar extends SnackBar {
  DeleteTodoSnackBar({
    Key key,
    @required TodoEntity todo,
    @required VoidCallback onUndo,
  }) : super(
          key: key,
          content: Text(
            todo.task,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          duration: Duration(seconds: 2),
          action: SnackBarAction(
            label: "undo",
            onPressed: onUndo,
          ),
        );
}
