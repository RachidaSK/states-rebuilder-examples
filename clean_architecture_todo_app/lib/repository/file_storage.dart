// Copyright 2018 The Flutter Architecture Sample Authors. All rights reserved.
// Use of this source code is governed by the MIT license that can be found
// in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:clean_architecture_todo_app/domain/entities/todo_entity.dart';
import 'package:clean_architecture_todo_app/service/exceptions/curd_exceptions.dart';

/// Loads and saves a List of Todos using a text file stored on the device.
///
/// Note: This class has no direct dependencies on any Flutter dependencies.
/// Instead, the `getDirectory` method should be injected. This allows for
/// testing.
class FileStorage {
  final String tag;
  final Future<Directory> Function() getDirectory;

  const FileStorage(
    this.tag,
    this.getDirectory,
  );

  Future<List<TodoEntity>> loadTodos() async {
    try {
      if (Random().nextBool() && Random().nextBool()) {
        throw Exception();
      }
      final file = await _getLocalFile();
      final string = await file.readAsString();
      final json = JsonDecoder().convert(string);
      final todos = (json['todos'])
          .map<TodoEntity>((todo) => TodoEntity.fromJson(todo))
          .toList();

      return todos;
    } catch (e) {
      throw TodosNotFoundException(
          'I/O Error. Failed to read from your device');
    }
  }

  Future<File> saveTodos(List<TodoEntity> todos) async {
    try {
      if (Random().nextBool() && Random().nextBool()) {
        throw Exception();
      }
      final file = await _getLocalFile();

      return file.writeAsString(JsonEncoder().convert({
        'todos': todos.map((todo) => todo.toJson()).toList(),
      }));
    } catch (e) {
      throw SaveTodoException('A I/O Error.. Failed to wite in your device');
    }
  }

  Future<File> _getLocalFile() async {
    final dir = await getDirectory();

    return File('${dir.path}/ArchSampleStorage__$tag.json');
  }

  Future<FileSystemEntity> clean() async {
    final file = await _getLocalFile();

    return file.delete();
  }
}
