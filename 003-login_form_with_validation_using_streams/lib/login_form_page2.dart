import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import 'login_form_model.dart';

class LoginFormPage2 extends StatelessWidget {
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
          body: Container(
            margin: EdgeInsets.all(20),
            child: ListView(
              children: <Widget>[
                StateBuilder(
                  models: [email],
                  builder: (context, _) {
                    print('email is rebuilt');
                    return TextField(
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: "your@email.com. It should contain '@'",
                        labelText: "Email Address",
                        errorText: email.error,
                      ),
                      onChanged: model.changeEmail,
                    );
                  },
                ),
                StateBuilder(
                  models: [password],
                  builder: (context, _) {
                    print('password is rebuild');
                    return TextField(
                      onChanged: model.changePassword,
                      decoration: InputDecoration(
                          hintText:
                              "Password should be more than three characters",
                          labelText: 'Password',
                          errorText: password.error),
                    );
                  },
                ),
                StateBuilder(
                  models: [email, password],
                  builder: (context, _) {
                    print('Login button is rebuild');
                    return RaisedButton(
                      child: Text("login"),
                      onPressed: email.hasData && password.hasData
                          ? () {
                              model.submit();
                            }
                          : null,
                    );
                  },
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
