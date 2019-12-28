// Copyright 2018 The Flutter Architecture Sample Authors. All rights reserved.
// Use of this source code is governed by the MIT license that can be found
// in the LICENSE file.

import 'package:clean_architecture_todo_app/domain/entities/todo_entity.dart';
import 'package:flutter/material.dart';

typedef OnSaveCallback = Function(String task, String note);

class AddEditScreen extends StatefulWidget {
  final bool isEditing;
  final OnSaveCallback onSave;
  final TodoEntity todo;

  AddEditScreen({
    Key key,
    @required this.onSave,
    @required this.isEditing,
    this.todo,
  });

  @override
  _AddEditScreenState createState() => _AddEditScreenState();
}

class _AddEditScreenState extends State<AddEditScreen> {
  static final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String _task;
  String _note;

  bool get isEditing => widget.isEditing;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? "Edit todo" : "Add todo",
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: isEditing ? widget.todo.task : '',
                autofocus: !isEditing,
                style: textTheme.headline,
                decoration: InputDecoration(
                  hintText: "New todo",
                ),
                validator: (val) {
                  return val.trim().isEmpty ? "Empty todo" : null;
                },
                onSaved: (value) => _task = value,
              ),
              TextFormField(
                initialValue: isEditing ? widget.todo.note : '',
                maxLines: 10,
                style: textTheme.subhead,
                decoration: InputDecoration(
                  hintText: "Notes",
                ),
                onSaved: (value) => _note = value,
              )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: isEditing ? "Save Changes" : "Add todo",
        child: Icon(isEditing ? Icons.check : Icons.add),
        heroTag: UniqueKey().toString(),
        onPressed: () {
          if (_formKey.currentState.validate()) {
            _formKey.currentState.save();
            widget.onSave(_task, _note);

            Navigator.pop(context);
          }
        },
      ),
    );
  }
}
