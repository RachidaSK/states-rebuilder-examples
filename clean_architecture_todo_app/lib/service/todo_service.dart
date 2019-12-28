import 'package:clean_architecture_todo_app/domain/entities/todo_entity.dart';

import 'interfaces/i_todos_repository.dart';
import 'utils/enums.dart';

class TodoService {
  TodoService(this.todosRepository);

  final ITodosRepository todosRepository;

  List<TodoEntity> _todos = [];
  VisibilityFilter activeFilter = VisibilityFilter.all;

  List<TodoEntity> get todos {
    if (activeFilter == VisibilityFilter.all) {
      return _todos;
    } else {
      return _todos.where((todo) {
        if (activeFilter == VisibilityFilter.active) {
          return !todo.complete;
        } else {
          return todo.complete;
        }
      }).toList();
    }
  }

  int get numActive => _todos.where((todo) => !todo.complete).length;
  int get numCompleted => _todos.where((todo) => todo.complete).length;

  loadTodos() async {
    _todos = await this.todosRepository.loadTodos();
  }

  addTodo(TodoEntity todoToAdd) async {
    _todos.add(todoToAdd);
    await _saveTodos(_todos);
  }

  updateTodo(TodoEntity todoToUpdate) async {
    final List<TodoEntity> updatedTodos = _todos.map((todo) {
      return todo.todoID == todoToUpdate.todoID ? todoToUpdate : todo;
    }).toList();
    _todos = updatedTodos;
    await _saveTodos(_todos);
  }

  deleteTodo(TodoEntity todoToDelete) async {
    await _saveTodos(_todos);
    _todos.removeWhere((todo) => todo.todoID == todoToDelete.todoID);
  }

  clearCompletedTodos() async {
    await _saveTodos(_todos);
    _todos.removeWhere((todo) => todo.complete);
  }

  toggleAll() async {
    final isAllCompleted = _todos.every((todo) => todo.complete);

    _todos.forEach((todo) {
      todo.complete = !isAllCompleted;
    });

    await _saveTodos(_todos);
  }

  Future _saveTodos(List<TodoEntity> todos) async {
    return await todosRepository.saveTodos(todos);
  }
}
