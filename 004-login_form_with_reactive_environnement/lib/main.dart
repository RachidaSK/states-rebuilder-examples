import 'package:flutter/material.dart';

import 'login_form_page.dart';

void main() => runApp(
      MaterialApp(
        home: App(),
      ),
    );

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: LoginFormPage1()),
    );
  }
}
