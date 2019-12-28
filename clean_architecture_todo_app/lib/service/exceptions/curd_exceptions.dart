class TodosNotFoundException extends Error {
  TodosNotFoundException(this.message);
  final String message;
}

class SaveTodoException extends Error {
  SaveTodoException(this.message);
  final String message;
}
