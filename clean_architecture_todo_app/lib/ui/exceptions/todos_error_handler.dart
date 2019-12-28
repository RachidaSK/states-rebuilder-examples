import 'package:clean_architecture_todo_app/service/exceptions/curd_exceptions.dart';
import 'package:flutter/material.dart';

class TodosErrorHandler {
  static void errorHandler(BuildContext context, dynamic error) {
    print(error);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Builder(
            builder: (context) {
              if (error is TodosNotFoundException) {
                return Text(error.message);
              }
              if (error is SaveTodoException) {
                return Text(error.message);
              }
              throw error;
            },
          ),
        );
      },
    );
  }
}
