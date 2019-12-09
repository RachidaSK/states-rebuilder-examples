import 'package:flutter/material.dart';

import 'login_form_page1.dart';
import 'login_form_page2.dart';

void main() => runApp(
      MaterialApp(
        home: App(),
      ),
    );

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            RaisedButton(
              child: Text('Login Form with Stream'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginFormPage1(),
                  ),
                );
              },
            ),
            RaisedButton(
              child: Text('Login Form with Stream (fine-tuned rebuild'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginFormPage2(),
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
