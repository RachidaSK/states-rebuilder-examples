// Copyright 2018 The Flutter Architecture Sample Authors. All rights reserved.
// Use of this source code is governed by the MIT license that can be found
// in the LICENSE file.

import 'dart:async';
import 'dart:math';

import 'package:clean_architecture_todo_app/domain/entities/todo_entity.dart';
import 'package:clean_architecture_todo_app/service/exceptions/curd_exceptions.dart';

/// A class that is meant to represent a Client that would be used to call a Web
/// Service. It is responsible for fetching and persisting Todos to and from the
/// cloud.
///
/// Since we're trying to keep this example simple, it doesn't communicate with
/// a real server but simply emulates the functionality.
class WebClient {
  final Duration delay;

  const WebClient([this.delay = const Duration(milliseconds: 3000)]);

  /// Mock that "fetches" some Todos from a "web service" after a short delay
  Future<List<TodoEntity>> fetchTodos() async {
    try {
      if (Random().nextBool() && Random().nextBool()) {
        throw Exception();
      }

      return Future.delayed(
          delay,
          () => [
                TodoEntity(
                  'Buy food for da kitty',
                  '1',
                  'With the chickeny bits!',
                  false,
                ),
                TodoEntity(
                  'Find a Red Sea dive trip',
                  '2',
                  'Echo vs MY Dream',
                  false,
                ),
                TodoEntity(
                  'Book flights to Egypt',
                  '3',
                  '',
                  true,
                ),
                TodoEntity(
                  'Decide on accommodation',
                  '4',
                  '',
                  false,
                ),
                TodoEntity(
                  'Sip Margaritas',
                  '5',
                  'on the beach',
                  true,
                ),
              ]);
    } catch (e) {
      throw TodosNotFoundException(
          'A netWork Error. Failed to get your todos from the claud');
    }
  }

  /// Mock that returns true or false for success or failure. In this case,
  /// it will "Always Succeed"
  Future<bool> postTodos(List<TodoEntity> todos) async {
    try {
      if (Random().nextBool() && Random().nextBool()) {
        throw Exception();
      }
      return Future.value(true);
    } catch (e) {
      if (Random().nextBool()) {
        throw SaveTodoException(
            'A netWork Error. Failed to update Todos in the Claud');
      }
      throw Exception('Unhandled error');
    }
  }
}
