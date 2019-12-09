# login_form_with_validation_using_streams

This example consists of a login form with two fields (one for the email and the other for the password) and a login button. The login button is inactive until both fields are validated.

 In this example, we will use streams like in BloC pattern.

 # The model:

 ```dart
 import 'dart:async';

class LoginFormModel {
  final emailController = StreamController<String>();
  final passwordController = StreamController<String>();

  Function(String) get changeEmail => emailController.sink.add;
  Function(String) get changePassword => passwordController.sink.add;

  Stream<String> get email => emailController.stream.transform(validateEmail);
  Stream<String> get password =>
      passwordController.stream.transform(validatePassword);

  submit() {
    print("form submitted");
  }

  //The validation of the email. It must contain @
  final validateEmail = StreamTransformer<String, String>.fromHandlers(
    handleData: (email, sink) {
      if (email.contains("@")) {
        sink.add(email);
      } else {
        sink.addError("Enter a valid Email");
      }
    },
  );

  //The validation of the password. It must have more than three characters
  final validatePassword = StreamTransformer<String, String>.fromHandlers(
    handleData: (password, sink) {
      if (password.length > 3) {
        sink.add(password);
      } else {
        sink.addError("Enter a valid password");
      }
    },
  );

  //Disposing the controllers
  dispose() {
    emailController.close();
    passwordController.close();
    print("controllers are disposed");
  }
}

 ```

# The user interface

```dart
import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import 'login_form_model.dart';

class LoginFormPage1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Injector(
      inject: [
        //NOTE1: Inject LoginFormModel
        Inject(() => LoginFormModel()),
        //NOTE1: Get the email stream from the injected LoginFormModel and inject it as stream
        //NOTE1: email stream in injected using a custom name.
        Inject.stream(() => Injector.get<LoginFormModel>().email,
            name: "emailStream"),

        //NOTE1: Get the password stream from the injected LoginFormModel and inject it as stream
        //NOTE1: password stream in injected using a custom name.
        Inject.stream(() => Injector.get<LoginFormModel>().password,
            name: "passwordStream"),
      ],
      //NOTE2: controller need to be disposed.
      disposeModels: true,
      builder: (context) {
        //TODO
        
      },
    );
  }
}
```


First of all, we inject the model `LoginFormModel`. From the injected instance of `LoginFormModel` we can obtain the email and password streams and inject them using `Injector.stream` to make the steams available in the widget tree and widget can subscribe and get notified when the injected streams emit a value.[NOTE1]

>With states_rebuilder injected model are available for access even in the inject parameter. The order of injection of dependent models.

In our case, although `Inject.stream` depends on `LoginFormModel` injected instance, the `LoginFormModel` is the last injected element. This is feasible because the order of the injection of models is not mandatory.

```dart
Injector(
      inject: [
        //get the email stream and inject it as stream
        Inject.stream(() => Injector.get<LoginFormModel>().email,
            name: "emailStream"),

        //get the password stream and inject it as stream
        Inject.stream(() => Injector.get<LoginFormModel>().password,
            name: "passwordStream"),

        // LoginFormModel is last in the list.
        Inject(() => LoginFormModel()),
      ],
```

The `disposeModels` parameter is set to true to clean injected model when the `Injector` widget is disposed. This means that if any of the injected models have a `dispose()` method, then `dispose()` method will be called to free resources after removing the `Injector` widget from the widget tree.[NOTE2]

Let's continue with our example:

```dart
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
      disposeModels: true,
      builder: (context) {
        //NOTE1: Getting the injected model and streams
        final model = Injector.get<LoginFormModel>();

        //NOTE2: using the defined custom names
        final email = Injector.getAsReactive<String>(name: "emailStream");
        final password = Injector.getAsReactive<String>(name: "passwordStream");

        return Scaffold(
          appBar: AppBar(
            title: Text('Login Form'),
          ),
          body: StateBuilder(
            //NOTE3: This StateBuilder subscribes to the email and password stream. If any of the streams emit a value this widget will be notified to rebuild.
            models: [email, password],
            builder: (context, _) {
              
            },
          ),
        );
      },
    );
  }
}
```

We get the registered raw instance of the `LoginFormModel` model using `Injector.get` method. This is because the `LoginFormModel` singleton will be only used to add sinks to email and password StreamControllers.[NOTE1]

Injected streams are obtained using the custom names they registered with without the context parameter.[NOTE2]

>With states_rebuilder, it is considered an error to get a registered model with a custom name using the context. This is because the context is used to subscribe the context to an InheritedWidget which relies on types, not names. 

To subscribe to a model obtained using a custom name, we have to use the `StateBuilder` widget. [NOTE3]

The remainder of the code is self-explanatory.

```dart
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
        return Scaffold(
          appBar: AppBar(
            title: Text('Login Form'),
          ),
          body: StateBuilder(
            models: [email, password],
            builder: (context, _) {

              return Container(
              child: ListView(
                children: <Widget>[
                  TextField(
                    //Add the entered text to changeEmail sink.
                    //After validation, the email stream emits either an error or data and notify observer widget
                    onChanged: model.changeEmail,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: "your@email.com. It should contain '@'",
                      labelText: "Email Address",
                      //The emitted error message.
                      errorText: email.error,
                    ),
                  ),
                  TextField(
                    //Add the entered text to changePassword sink.
                    //After validation, the password stream emits either an error or data and notify observer widget
                    onChanged: model.changePassword,
                    decoration: InputDecoration(
                        hintText:
                            "Password should be more than three characters",
                        labelText: 'Password',
                        //The emitted error message.
                        errorText: password.error,
                      ),
                  ),
                  RaisedButton(
                    child: Text("login"),
                    //Login button will not be active until both email and password has data.
                    onPressed: email.hasData && password.hasData
                        ? () {
                            model.submit();
                          }
                        : null,
                  ),
                ],
              ),
              margin: EdgeInsets.all(20),
            );
            },
          ),
        );
      },
    );
  }
}
```

In this example, all the body widget of the scaffold will be rebuild when any of email or password stream emits a notification.

# Control the rebuilds:

To refine the rebuilding process so that if the email stream emits a notification, only the email field will be rebuilt and likewise for the password stream and field, we use the `StateBuilder` widget.

```dart
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

        // print log to track rebuild
        print('Scaffold widget is rebuilt');
        return Scaffold(
          appBar: AppBar(
            title: Text('Login Form'),
          ),
          body: Container(
            margin: EdgeInsets.all(20),
            child: ListView(
              children: <Widget>[

                //NOTE1: Email field is wrapped by StateBuilder to subscribe to email stream only
                //Wehner the email stream emits a data only this StateBuilder will rebuild
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

                //NOTE2: Password field is wrapped ba a StateBuilder tha subscribe to password stream only
                //Wehner the password stream emits a data only this StateBuilder will rebuild
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

                //NOTE3: Login button is wrapped ba a StateBuilder tha subscribe to both email and password streams
                //Wehner the email or password stream emits a data only this StateBuilder will rebuild
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
```
