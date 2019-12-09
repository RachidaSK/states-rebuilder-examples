import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import 'login_form_model.dart';

class LoginFormPage1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Injector(
      inject: [
        Inject(() => LoginFormModel()),
        Inject.stream(() => Injector.get<LoginFormModel>().email,
            name: "emailStream"),
        Inject.stream(() => Injector.get<LoginFormModel>().password,
            name: "passwordStream"),
      ],
      //controller need to be disposed.
      disposeModels: true,
      builder: (context) {
        final model = Injector.get<LoginFormModel>();
        final email = Injector.getAsReactive<String>(name: "emailStream");
        final password = Injector.getAsReactive<String>(name: "passwordStream");

        print('Scaffold widget is rebuilt');

        return Scaffold(
          appBar: AppBar(
            title: Text('Login Form'),
          ),
          body: StateBuilder(
            models: [email, password],
            builder: (context, _) {
              return Container(
                margin: EdgeInsets.all(20),
                child: ListView(
                  children: <Widget>[
                    Container(),
                    TextField(
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: "your@email.com. It should contain '@'",
                        labelText: "Email Address",
                        errorText: email.error,
                      ),
                      onChanged: model.changeEmail,
                    ),
                    TextField(
                      onChanged: model.changePassword,
                      decoration: InputDecoration(
                          hintText:
                              "Password should be more than three characters",
                          labelText: 'Password',
                          errorText: password.error),
                    ),
                    RaisedButton(
                      child: Text("login"),
                      onPressed: email.hasData && password.hasData
                          ? () {
                              model.submit();
                            }
                          : null,
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
