import 'package:flutter/material.dart';

import '../../domain/exceptions/email_exception.dart';
import '../../service/exceptions/fetch_exception.dart';
import '../../service/exceptions/input_exception.dart';

class ErrorHandler {
  static String errorMessage(dynamic error) {
    if (error == null) {
      return null;
    }
    if (error is EmailException) {
      return error.message;
    }

    if (error is NotNumberException) {
      return error.message;
    }

    if (error is NetworkErrorException) {
      return error.message;
    }

    if (error is UserNotFoundException) {
      return error.message;
    }

    if (error is PostNotFoundException) {
      return error.message;
    }

    if (error is CommentNotFoundException) {
      return error.message;
    }

    throw error;
  }

  static void showErrorDialog(BuildContext context, dynamic error) {
    if (error == null) {
      return;
    }
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text(errorMessage(error)),
        );
      },
    );
  }
}
