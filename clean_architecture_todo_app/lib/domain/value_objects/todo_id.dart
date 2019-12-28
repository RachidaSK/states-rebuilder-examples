import 'package:flutter/material.dart';

class TodoID {
  TodoID([String id]) {
    _id = id != null ? UniqueKey().toString() : id;
  }

  String _id;
  String get id => _id;

  @override
  String toString() {
    return '$_id';
  }
}
