// Copyright 2018 The Flutter Architecture Sample Authors. All rights reserved.
// Use of this source code is governed by the MIT license that can be found
// in the LICENSE file.

import '../value_objects/todo_id.dart';

class TodoEntity {
  bool complete;
  TodoID todoID;
  String note;
  String task;

  TodoEntity(this.task, String id, this.note, this.complete)
      : this.todoID = id == null ? TodoID() : TodoID(id);

  Map<String, Object> toJson() {
    return {
      "complete": complete,
      "task": task,
      "note": note,
      "id": todoID.id,
    };
  }

  static TodoEntity fromJson(Map<String, Object> json) {
    return TodoEntity(
      json["task"] as String,
      json["id"] as String,
      json["note"] as String,
      json["complete"] as bool,
    );
  }

  @override
  String toString() {
    return 'TodoEntity{complete: $complete, task: $task, note: $note, id: ${todoID.id}}';
  }
}
