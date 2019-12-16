# login_form_with_reactive_environment

This example consists of a login form with two fields (one for the email and the other for the password) and a login button. The login button is inactive until both fields are validated.

<image src="https://github.com/GIfatahTH/repo_images/blob/master/004-form_login_with_validation.gif" width="300"/>

In this example, we will not use stream but we will use a simple dart class.

# Model:

```dart
import 'login_form_error.dart';

class LoginFormModel {
  String email;
  String password;

  void setEmail(String email) {
    //The validation of the email. It must contain @
    if (!email.contains("@")) {
      throw LoginError("Enter a valid Email");
    }
    this.email = email;
  }

  void setPassword(String password) {
    //The validation of the password. It must have more than three characters
    if (password.length <= 3) {
      throw LoginError('Enter a valid password');
    }
    this.password = password;
  }

  submit() {
    print("form submitted");
  }
}
```

# Error

```dart
class LoginError extends Error {
  LoginError(this.message);
  final String message;
}
```

There is nothing special, simple vanilla dart classes.

# User Interface

```dart
import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import 'login_form_model.dart';

class LoginFormPage1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Injector(
      inject: [
        //NOTE1: Injecting the LoginFormModel model
        Inject(
          () => LoginFormModel(),
          //TODO: 
          //NOTE2 : join reactive singleton with the combined result of the new reactive instances
          //joinSingleton: JoinSingleton.withCombinedReactiveInstances,
        ),
      ],
      //controller need to be disposed.
      disposeModels: true,
      builder: (context) {
        
        //NOTE3: obtaining the injected reactive singleton of LoginFormModel model
        final model = Injector.getAsReactive<LoginFormModel>();


        return Scaffold(
          appBar: AppBar(
            title: Text('Login Form'),
          ),
          body: Container(
            margin: EdgeInsets.all(20),
            child: ListView(
              children: <Widget>[
                  //To be continued.
              ],
            ),
          ),
        );
      },
    );
  }
}
```

As usual the first thing in to inject an instance of the `LoginFormModel` model. [NOTE1].

In this example, we will see how can new reactive instances share their state withthe reactive singleton. [NOTE2]. We will talk about it later on.

The `ListView` will contain the email and password TextFields and login button.

```dart
class LoginFormPage1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Injector(
      inject: [
        Inject(
          () => LoginFormModel(),
          //TODO: 
          //NOTE2 : join reactive singleton with the combined result of the new reactive instances
          //joinSingleton: JoinSingleton.withCombinedReactiveInstances,
        ),
      ],
      disposeModels: true,
      builder: (context) {
        final singletonModel = Injector.getAsReactive<LoginFormModel>();

        print('Scaffold widget is rebuilt');

        return Scaffold(
          appBar: AppBar(
            title: Text('Login Form'),
          ),
          body: Container(
            margin: EdgeInsets.all(20),
            child: ListView(
              children: <Widget>[
                //NOTE1: First new reactive instance for email input
                StateBuilder<LoginFormModel>(
                  builder: (context, loginModel) {
                    return TextField(
                      onChanged: (String email) {
                        //NOTE3 : Using setState to call setEmail method
                        loginModel.setState(
                          (state) => state.setEmail(email),

                          //NOTE4: Set catchError to true, so app will not break.
                          catchError: true,
                        );
                      },
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: "your@email.com. It should contain '@'",
                        labelText: "Email Address",

                        //NOTE5: Check if model throw an error and display it.
                        errorText: loginModel.hasError
                            ? loginModel.error.message
                            : null,
                      ),
                    );
                  },
                ),

                //NOTE1: Second new reactive instance for password input
                StateBuilder<LoginFormModel>(
                  builder: (context, loginModel) {
                    return TextField(
                      onChanged: (String email) {
                        //NOTE3 : Using setState to call setPassword method
                        loginModel.setState(
                          (state) => state.setPassword(email),

                          //NOTE4: Set catchError to true, so app will not break.
                          catchError: true,
                        );
                      },
                      decoration: InputDecoration(
                        hintText:
                            "Password should be more than three characters",
                        labelText: 'Password',

                        //NOTE5: Check if model throw an error and display it.
                        errorText: loginModel.hasError
                            ? loginModel.error.message
                            : null,
                      ),
                    );
                  },
                ),

                //NOTE6: This StateBuilder is subscribe to the reactive singleton model obtained with Injector.getAsReactive
                StateBuilder(
                  models: [singletonModel],
                  builder: (context, _) {
                    return RaisedButton(
                      child: Text("login"),

                      //NOTE7: Check if model has data to activate the button.
                      onPressed: singletonModel.hasData
                          ? () {
                              singletonModel.state.submit();
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

```

states_rebuilder caches two singletons one for the raw injected model and one for the same raw model but decorated with a reactive layer.

To get the the raw singleton, we use:
```dart
final LoginFormModel model = Injector.get<LoginFormModel>();
```

To get the the reactive singleton, we use:
```dart
final ReactiveModel<LoginFormModel> model = Injector.getAsReactive<LoginFormModel>();
```

with states_rebuilder you can obtain the same raw singleton of the model but decorated with a new reactive layer.

This can be done with two ways:

```dart
final ReactiveModel<LoginFormModel> reactiveModelInstance = Injector.getAsReactive<LoginFormModel>(asNewReactiveInstance: true);

//And subscribe widget to it using `StateBuilder`
StateBuilder<LoginFormModel>(
    models: [reactiveModelInstance]
    builder: (BuildContext context, ReactiveModel<LoginFormModel> reactiveModelInstance){

    }
)
```

Or as a shortcut, by using the `StateBuilder` with generic type and without `models` parameter :

```dart
StateBuilder<LoginFormModel>(
    builder: (BuildContext context, ReactiveModel<LoginFormModel> reactiveModelInstance){

    }
)
```

In this example, we have created two new reactive instances one for the email and one for the password. [NOTE1]

The two email and password reactive environments are totally independent. For example, If one throws the other reactive environment will not be affected.

To mutate the model state and notify subscribers, you use `setState` method. [NOTE3].

We are sure that the `setEmail` and `setPassword` has a chance to throw, so we set the parameter `catchError` fo the `setState` method to true to not break the app.[NOTE4].

To check if the reactive environment has an error, we sue the `hasError` getter and to use the thrown error, we use the `error` getter. [NOTE5].

Lastly, we wrapped the login button with a `StateBuilder` widget that is subscribed to the reactive singleton. [NOTE6]. 

In [NOTE7], we checked if the model `hasData` and activate the login button.

In the example, we have one reactive singleton (there is always one) and two new reactive instances. Each reactive instance lives in its own world independently to other reactive environments. The only thing the reactive instances share is the raw singleton of the injected model.

with states_rebuilder new reactive instances can clone their state to the reactive singleton. This can be done by setting the `joinSingleton` in the constructor of the `Inject` class.

We have two types of interaction between new and singleton instances:
* `JoinSingleton.witReactiveInstances` : This means that when a reactive instance emits a  notification, its state will be cloned in the reactive singleton.   
ex: In our example if we set the `joinSingleton` to `JoinSingleton.witReactiveInstances`, and if the email emits a notification with error the login button hasData is false and the button is inactive. and the opposite is true, if the email emits a notification without error, the login button hasData is true and the button is active regardless of the state of the password reactive environment.

* `JoinSingleton.withCombinedReactiveInstances` : This means that when a reactive instance emits a notification, a combined state of all new reactive instances will be transmitted to the reactive singleton.  
ex: If the email reactive environment emits a notification without error the state of the login button reactive environment will depend on the state of the password reactive environment.

The logic of combining reactive instances is the following:

* Priority 1- The combined `ReactiveModel.hasError` is true if at least one of the new instances has an error    
* Priority 2- The combined `ReactiveModel.connectionState` is awaiting if at least one of the new instances is awaiting.    
* Priority 3- The combined `ReactiveModel.connectionState` is 'none' if at least one of the new instances is 'none'.     
* Priority 4- The combined `ReactiveModel.hasDate` is true if it has no error, isn't awaiting  and is not in 'none' state.

NB: The logic is similar to combining streams with rxDart.

Uncomment [NOTE2] in the code and you will see that it works just like in the case with streams.

```dart
inject: [
    Inject(
        () => LoginFormModel(),
        
        //NOTE2 : join reactive singleton with the combined result of the new reactive instances
        joinSingleton: JoinSingleton.withCombinedReactiveInstances,
    ),
],
```

* `joinSingletonWith` can be defined in `setState` method or in `Inject` class constructor. When set in the `setState` method, it means that only the new instance, where` setState` is called, is joined to the reactive singleton. Whereas if `joinSingletonWith` is defined in the` Inject` constructor, this means that all new reactive instances will be joined to the reactive singleton.
