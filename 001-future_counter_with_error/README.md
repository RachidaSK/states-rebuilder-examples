# future_counter_with_error

This is a counter application that increments a counter after waiting 1 second and has a 1/2 probability of generating an error. If an error is thrown, an alert dialog will appear giving information about the error.

# Model

*file : counter.dart*

```dart
class Counter {
  Counter(this.count);
  int count;

  void increment() {
    count++;
  }
}
```
# Error
To handle error it is very convenient to use your custom error classes.

*file : counter_error.dart*

```dart
class CounterError extends Error {
  final String message = 'A permission issue, please contact your administrator';
}
```



# Service
The role of the `CounterService` class is to instantiate the counter (usually via the repository) and define the user cases to be used by the user interface.


```dart
import 'dart:math';

import 'counter.dart';
import 'counter_error.dart';

class CounterService {
  CounterService() {
    counter = Counter(0);
  }
  Counter counter;

  Future<void> increment() async {
    await Future.delayed(Duration(seconds: 1));

    if (Random().nextBool()) {
      throw CounterError();
    }

    counter.increment();
  }
}
```

>This is all the business logic of your app. It is testable , maintainable and framework independent. 

# User Interface

*file : counter_page.dart*

The first thing is to inject `CounterService` in the widget tree at the level where we want it to be available. 
For this simple example, we can inject it at the `home` parameter of the `MaterialApp` widget.
```dart
import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import 'counter_service.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Future Counter with Error',
      home: Injector(
        inject: [Inject(() => CounterService())],
        builder: (BuildContext context) {
          return CounterPage();
        },
      ),
    );
  }
}
```

Now a singleton of `CounterService` is accessible to `CounterPage` widget and its children.

In `CounterPage` we first get the reactive singleton using `Injector.getAsReactive` method.

```dart
class CounterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ReactiveModel<CounterService> counterService = Injector.getAsReactive(context: context);
   return Scaffold(
       ....
   )
  }
}
```
 the fill method declaration to get the reactive singleton is with return and generic type:

 ```dart
 final ReactiveModel<CounterService> counterService = Injector.getAsReactive<CounterService> (context: context);
 ```

or with less boilerplate,

 ```dart
 final counterService = Injector.getAsReactive<CounterService> (context: context);
 ```
 because dart can infer the return type.

 or 
```dart
 final ReactiveModel<CounterService> counterService = Injector.getAsReactive(context: context);
 ```
 because dart can infer the generic type.


Now `counterService` is available and has many useful getter and methods:

Because we are dealing with asynchronous task, we need `connectionState` and `hasError` getters

```dart
class CounterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ReactiveModel<CounterService> counterService =
        Injector.getAsReactive(context: context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Future counter with error'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
              //Flutter Builder widget is very useful to use if you want to conditionals return widgets.
            Builder(
              builder: (BuildContext context) {
                //Before requesting the asynchronous method. (At the start of the app)
                if (counterService.connectionState == ConnectionState.none) {
                  return Text(
                      'Top on the plus button to start incrementing the counter');
                }

                //while waiting for the asynchronous method to complete
                if (counterService.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }

                //If the asynchronous method completes with error.
                if (counterService.hasError) {
                  return Text(
                    counterService.error.message,
                    style: TextStyle(color: Colors.red),
                  );
                }

                //If the asynchronous method completes with data.
                return Text(' ${counterService.state.counter.count}');
              },
            ),
            IconButton(
              icon: Icon(Icons.add),
              iconSize: 40,
              onPressed: () {
                  //To trigger events or action 
                  .....
              },
            )
          ],
        ),
      ),
    );
  }
}
 ```
To trigger a method that will mutate the state and notify listeners, we sue `setState` method.

```dart
IconButton(
    icon: Icon(Icons.add),
    iconSize: 40,
    onPressed: () {
        counterService.setState(
            //increment counter and notify listeners
            (state) => state.increment(),
            //We expect errors and want to catch them
            catchError: true,
        );
    },
)

```

To display an AlertDialog when the error is thrown, we use `onSetState` parameter of the `setState` method.
`onSetState` and `onRebuildState` are used to execute side effects after state mutation and before rebuilding for `onSetState` adn after rebuilding for `onRebuildState`.

```dart
IconButton(
    icon: Icon(Icons.add),
    iconSize: 40,
    onPressed: () {
    counterService.setState(
        (state) => state.increment(),
        catchError: true,
        onSetState: (BuildContext context) {
        if (counterService.hasError) {
            showDialog(
            context: context,
            builder: (context) {
                return AlertDialog(
                title: Icon(Icons.error),
                content: Text(counterService.error.message),
                );
            },
            );
        }
        },
    );
    },
)
```
# StateBuilder

This is the same example this time using `StateBuilder` widget
The differences are:
* `Injector.getAsReactive` is called without context.
* `onSetState` of the `StateBuilder` widget is used instead of that of `setState`.

> `onSetState` of `setState` is for one time call after triggering the event.    
> `onSetState` of` StateBuilder` is called whenever `StateBuilder` is notified, no matter where the notification comes from.

```dart
class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Future Counter with Error',
      home: Injector(
        inject: [Inject(() => CounterService())],
        builder: (BuildContext context) {
          return CounterPage();
        },
      ),
    );
  }
}

class CounterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //The context is not used
    final counterService = Injector.getAsReactive<CounterService>();
    return Scaffold(
      appBar: AppBar(
        title: Text('Future counter with error'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            StateBuilder(
              models: [counterService],
              onSetState: (BuildContext context, _) {
                if (counterService.hasError) {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Icon(Icons.error),
                        content: Text(counterService.error.message),
                      );
                    },
                  );
                }
              },
              builder: (BuildContext context, _) {
                if (counterService.connectionState == ConnectionState.none) {
                  return Text(
                      'Top on the plus button to start incrementing the counter');
                }
                if (counterService.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }

                if (counterService.hasError) {
                  return Text(
                    counterService.error.message,
                    style: TextStyle(color: Colors.red),
                  );
                }

                return Text(
                  ' ${counterService.state.counter.count}',
                  style: TextStyle(fontSize: 20),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.add),
              iconSize: 40,
              onPressed: () {
                counterService.setState(
                  (state) => state.increment(),
                  catchError: true,
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
```