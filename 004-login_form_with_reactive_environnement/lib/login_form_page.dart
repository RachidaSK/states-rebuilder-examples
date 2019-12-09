import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import 'login_form_model.dart';

class LoginFormPage1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Injector(
      inject: [
        Inject(
          () => LoginFormModel(),
          joinSingleton: JoinSingleton.withCombinedReactiveInstances,
        ),
      ],
      disposeModels: true,
      builder: (context) {
        final model = Injector.getAsReactive<LoginFormModel>();

        print('Scaffold widget is rebuilt');

        return Scaffold(
          appBar: AppBar(
            title: Text('Login Form'),
          ),
          body: Container(
            margin: EdgeInsets.all(20),
            child: ListView(
              children: <Widget>[
                StateBuilder<LoginFormModel>(
                  builder: (context, loginModel) {
                    return TextField(
                      onChanged: (String email) {
                        loginModel.setState(
                          (state) => state.setEmail(email),
                          catchError: true,
                        );
                      },
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: "your@email.com. It should contain '@'",
                        labelText: "Email Address",
                        errorText: loginModel.hasError
                            ? loginModel.error.message
                            : null,
                      ),
                    );
                  },
                ),
                StateBuilder<LoginFormModel>(
                  builder: (context, loginModel) {
                    return TextField(
                      onChanged: (String email) {
                        loginModel.setState(
                          (state) => state.setPassword(email),
                          catchError: true,
                        );
                      },
                      decoration: InputDecoration(
                        hintText:
                            "Password should be more than three characters",
                        labelText: 'Password',
                        errorText: loginModel.hasError
                            ? loginModel.error.message
                            : null,
                      ),
                    );
                  },
                ),
                StateBuilder(
                  models: [model],
                  builder: (context, _) {
                    return RaisedButton(
                      child: Text("login"),
                      onPressed: model.hasData
                          ? () {
                              model.state.submit();
                            }
                          : null,
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
