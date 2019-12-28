import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import '../../service/authentication_service.dart';
import '../exceptions/error_handler.dart';
import '../utils/app_colors.dart';
import '../widgets/login_header.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: backgroundColor,
        body: _LoginBody(controller: controller));
  }
}

class _LoginBody extends StatelessWidget {
  final controller;

  _LoginBody({this.controller});

  @override
  Widget build(BuildContext context) {
    final authService =
        Injector.getAsReactive<AuthenticationService>(context: context);

    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        LoginHeader(
          validationMessage: ErrorHandler.errorMessage(authService.error),
          controller: controller,
        ),
        authService.isWaiting
            ? CircularProgressIndicator()
            : FlatButton(
                color: Colors.white,
                child: Text(
                  'Login',
                  style: TextStyle(color: Colors.black),
                ),
                onPressed: () {
                  authService.setState(
                    (state) => state.login(controller.text),
                    catchError: true,
                    onSetState: (context) {
                      if (authService.hasData) {
                        Navigator.pushNamed(context, '/');
                      }
                    },
                  );
                },
              )
      ],
    );
  }
}
