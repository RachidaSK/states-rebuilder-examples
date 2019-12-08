# double_future_counter_with_error
# future_counter_with_error

This is a counter application that has two counter that share the same model. The first counter increments a counter after waiting 1 second and has a 1/2 probability of generating an error. Whereas the second counter do the same think but after waiting for 3 seconds.

If an error is thrown, an alert snackBar will appear giving information about the error.

This example has three pages:

* Page one : The tow counters will share the same reactive environnement. We will see how counter interfere with each other. I call this polluted environnement.
* Page two: This will show how to make the environnement clean using tags.
* Page three: It will show how to make the reactive environnement cleaner by creating new reactive environnement for each counter.


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

  Future<void> increment(int seconds) async {
    await Future.delayed(Duration(seconds: seconds));

    if (Random().nextBool()) {
      throw CounterError();
    } else {
      counter.increment();
    }
  }
}
```
`increment` method takes the second of the waiting as parameter.

>This is all the business logic of your app. It is testable , maintainable and framework independent. 

# User Interface

## Shared reactive environnement (polluted environnement):

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
    return Scaffold(
      appBar: AppBar(title: Text('Future counter with error')),
      body: Injector(
        inject: [Inject(() => CounterService())],
        builder: (BuildContext context) {

          //NOTE1 : Getting the countersService registered reactive environnement using the context.
          final ReactiveModel<CounterService> counterService =
              Injector.getAsReactive(context: context);

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              //NOTE2 : CounterPage widget for one second of waiting
              CounterPage(
                counterService: counterService,
                seconds: 1,
              ),
              //NOTE2 : CounterPage widget for three seconds of waiting
              CounterPage(
                counterService: counterService,
                seconds: 3,
              ),
            ],
          );
        },
      ),
    );
  }
}
```
After injecting the `CounterService` class, we get the registered singleton in the builder callback of the `Injector` widget.
>Injected models are available even within the `Injector` widget where they are injected.

the registered singleton of `CounterService` is obtained using `Injector.getAsReactive` with context, because we want this widget to be notified by the 'counterService' object. [NOTE1]

>If you want to get the registered reactive singleton and at the same time subscribe it to the obtained instance, you use `Injector.getAsReactive` with context. If the context is not available, you can get the reactive singleton `Injector.getAsReactive` without context and subscribe it to the model using `StateBuilder` widget.

`CounterPage` widget is written so that to be reusable and parametrized. It is use twice; the first for one second of wait ant the other for three seconds of wait. [NOTE2]

```dart
class CounterPage extends StatelessWidget {
  CounterPage({this.seconds, this.counterService});

  final int seconds;
  final ReactiveModel<CounterService> counterService;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Builder(
            builder: (BuildContext context) {
              //NOTE1: First return: When app first starts and before tapping on the increment button
              if (counterService.connectionState == ConnectionState.none) {
                return Text(
                    'Top on the plus button to increment the counter');
              }

              //NOTE1: Second return: When app is waiting for counter increment.
              if (counterService.connectionState == ConnectionState.waiting) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    CircularProgressIndicator(),
                    Text('$seconds second(s) wait'),
                  ],
                );
              }

              //NOTE1: Third return: If error is thrown.
              if (counterService.hasError) {
                return Text(
                  counterService.error.message,
                  style: TextStyle(color: Colors.red),
                );
              }

              //NOTE1: Forth return: counter value is available.
              return Text(
                ' ${counterService.state.counter.count}',
                style: TextStyle(fontSize: 30),
              );
            },
          ),

         IconButton(
            onPressed: () {
              //NOTE2 : To call a method that will mutate the state and notify listeners
              counterService.setState(
                (state) => state.increment(seconds),
                //NOTE2 : If increment method throws, it will not break the app.
                catchError: true,
                //NOTE2: Side effect to be executed after sending notification and before rebuilding observers
                onSetState: (BuildContext context) {
                  //NOTE3: context parameter of the onSetState is the context of the last add observer. In our cas it is the BuildContext of the Injector widget.
                  if (counterService.hasError) {
                    Scaffold.of(context).showSnackBar(
                      SnackBar(
                        content: Text(counterService.error.message),
                      ),
                    );
                  }
                },
              );
            },
            icon: Icon(
              Icons.add_circle,
              color: Theme.of(context).primaryColor,
            ),
            iconSize: 40,
          ),
        ],
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
      ),
      // Decoration of the Container
      height: 100,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(
          width: 2,
          color: Theme.of(context).primaryColor,
        ),
      ),
      margin: EdgeInsets.all(1),
    );
  }
}
```
`CounterPage` is a simple widget that displays a counter text with plus button to increment it. The display page depends on the reactive singleton `counterService` state. [NOTE1].

To Trigger an event that will mutate the state of the `counterService` and end by notifying subscribed widgets, we used `setState` method.[NOTE2].

`onSetState` callback will be called after sending notification and before rebuilding widgets. If you want to execute the callback after rebuilding listening widgets, use `onRebuildState`.

The BuildContext passed to the `onSetState` callback is of the BuildContext of the last added observer.

>states_rebuilder uses the observer pattern, to add observers to observable object, you either:
> * use `Injector.getAsReactive` method with the context parameter provided.
> * use `StateBuilder` widget.

> `onSetState` and `onRebuildState` can be called in `setState` method for one time use after calling `setState`, or in `StateBuilder` for each time a notification is sent form  models observed by the `StateBuilder` widget.

Try it and you can see that if one counter is incremented, it will affect the other counter because the two counter share the same reactive environnement.

## Shared reactive environnement (cleaning environnement with tags):

With states_rebuilder any time you want to have more control over when to send notification and which widgets will be notified to rebuild, you think directly to `StateBuilder` widget.

`StateBuilder` has a parameter called `tag`, which is used to mark it with a reference so that notification can be filtered by tags.

```dart
import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import 'counter_service.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Future counter with error')),
      body: Injector(
        inject: [Inject(() => CounterService())],
        builder: (BuildContext context) {
          //NOTE1: Getting the registered reactive singleton without the context
          final ReactiveModel<CounterService> counterService =
              Injector.getAsReactive();

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CounterPage(
                counterService: counterService,
                seconds: 1,
                //NOTE2: add the tag parameter
                tag: 'counter1',
              ),
              CounterPage(
                counterService: counterService,
                seconds: 3,
                //NOTE2: add the tag parameter
                tag: 'counter2',
              ),
            ],
          );
        },
      ),
    );
  }
}
```
The registered reactive singleton is obtained using `Injector.getAsReactive` without the context.[NOTE1]

>Whenever you use `StateBuilder` remove the context from `Injector.getAsReactive`, because `StateBuilder` subscribe to the model and is better for fine tune rebuild.

A `tag` is add to the `CounterPage` widget.

```dart
class CounterPage extends StatelessWidget {
  CounterPage({this.seconds, this.counterService, this.tag});
  final int seconds;
  final ReactiveModel<CounterService> counterService;
  //added tag field
  final String tag;
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          //NOTE1: use of StateBuilder widget
          StateBuilder(
            //NOTE1: subscription to the counterService model
            models: [counterService],
            //NOTE1: defining filtrating tag to this StateBuilder widget
            tag: tag,
            builder: (BuildContext context, _) {
              if (counterService.connectionState == ConnectionState.none) {
                return Text(
                    'Top on the plus button to start incrementing the counter');
              }
              if (counterService.connectionState == ConnectionState.waiting) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    CircularProgressIndicator(),
                    Text('$seconds second(s) wait'),
                  ],
                );
              }

              if (counterService.hasError) {
                return Text(
                  counterService.error.message,
                  style: TextStyle(color: Colors.red),
                );
              }

              return Text(
                ' ${counterService.state.counter.count}',
                style: TextStyle(fontSize: 30),
              );
            },
          ),
          IconButton(
            onPressed: () {
              counterService.setState(
                (state) => state.increment(seconds),
                //NOTE3: Defining list of tags to be notified.
                filterTags: [tag],
                catchError: true,
                onSetState: (BuildContext context) {
                  if (counterService.hasError) {
                    Scaffold.of(context).showSnackBar(
                      SnackBar(
                        content: Text(counterService.error.message),
                      ),
                    );
                  }
                },
              );
            },
            icon: Icon(
              Icons.add_circle,
              color: Theme.of(context).primaryColor,
            ),
            iconSize: 40,
          ),
        ],
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
      ),
      // Decoration of the Container
      height: 100,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(
          width: 2,
          color: Theme.of(context).primaryColor,
        ),
      ),
      margin: EdgeInsets.all(1),
    );
  }
}
```
`StateBuilder` is used instead of `Builder` widget as in the previous example. [NOTE1].

Now `SetState` method is called with `filterTags` parameter defined. It takes a list of tags to be used to filter the notification.

With this little change, counters looks like to function independently.

## New reactive environnement:

states_rebuilder caches two singletons for each registered model.
* Raw singleton of the model.
* reactive singleton of the model which is the raw singleton decorated with reactive environnement.

> `Injector.get<T>()` returns the raw singleton of type `T` of the registered model.    
> `Injector.getAsReactive<T>()` returns the reactive singleton of type `ReactiveModel<T>` of the registered model.  

With `states_rebuilder`, you can create, at any time, a new reactive instance, which is the same raw cashed singleton but decorated with a new reactive environment.

One way to create a new reactive instance of an injected model is to use `Injector.getAsReactive` with the  parameter `asNewReactiveInstance` equals true

```dart
// get a new reactive instance
ReactiveModel<T> model2 = Injector.getAsReactive<T>(asNewReactiveInstance: true);
```

For our case : 

```dart
import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import 'counter_service.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Future counter with error')),
      body: Injector(
        inject: [Inject(() => CounterService())],
        builder: (BuildContext context) {
          //NOTE1: Creating two new reactive instances
          final ReactiveModel<CounterService> counterService1 =
              Injector.getAsReactive(asNewReactiveInstance: true);
          final ReactiveModel<CounterService> counterService2 =
              Injector.getAsReactive(asNewReactiveInstance: true);

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CounterPage(
                //NOTE1: pass the new reactive instance counterService1
                counterService: counterService1,
                seconds: 1,
                //tag parameter is removed
              ),
              CounterPage(
                //NOTE1: pass the new reactive instance counterService2
                counterService: counterService2,
                seconds: 3,
              ),
            ],
          );
        },
      ),
    );
  }
}
```
>New reactive instances are not registered with in the service locator. Each time we call for new reactive instance we get another new reactive instance.

Another way to get new reactive instance is to use `StateBuilder` with generic type and without models property.
```dart
StateBuilder<T>(
  builder:(BuildContext context, T newReactiveModel){
    return YourWidget();
  }
)
```

In our case:

```dart
import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import 'counter_service.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Future counter with error')),
      body: Injector(
        inject: [Inject(() => CounterService())],
      builder: (BuildContext context) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              //NOTE1: Using StateBuilder with generic type and without models parameter
              StateBuilder<CounterService>(
                builder: (BuildContext context,
                    ReactiveModel<CounterService> counterService) {
                  return CounterPage(
                    //The second parameter of the builder callback is the created new reactive instance
                    counterService: counterService,
                    seconds: 1,
                  );
                },
              ),
              StateBuilder<CounterService>(
                builder: (BuildContext context, counterService) {
                  return CounterPage(
                    counterService: counterService,
                    seconds: 3,
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
```

>With the exception of the raw singleton they share, the reactive singleton and the new reactive instances have an independent reactive environment. That is, when a particular reactive instance issues a notification with an error or with `ConnectionState.awaiting`, it will not affect other reactive environments. Nevertheless `states_rebuilder` allows reactive instances to share their notification or state with the reactive singleton. (Object of new example).

The `CounterPage` widget is : 

```dart

class CounterPage extends StatelessWidget {
  CounterPage({this.seconds, this.counterService});
  final int seconds;
  final ReactiveModel<CounterService> counterService;
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
        //Use of `StateBuilder` without tag.
        //IF new reactive models are created with StateBuilder, we can use Builder here instead of this StateBuilder widget.
          StateBuilder(
            models: [counterService],
            builder: (BuildContext context, _) {
              if (counterService.connectionState == ConnectionState.none) {
                return Text(
                    'Top on the plus button to start incrementing the counter');
              }
              if (counterService.connectionState == ConnectionState.waiting) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    CircularProgressIndicator(),
                    Text('$seconds second(s) wait'),
                  ],
                );
              }

              if (counterService.hasError) {
                return Text(
                  counterService.error.message,
                  style: TextStyle(color: Colors.red),
                );
              }

              return Text(
                ' ${counterService.state.counter.count}',
                style: TextStyle(fontSize: 30),
              );
            },
          ),
          IconButton(
            onPressed: () {
              counterService.setState(
                (state) => state.increment(seconds),
                catchError: true,
                //NOTE1 : remove of filteredTag parameter. Notification is sent to all observers
                onSetState: (BuildContext context) {
                  if (counterService.hasError) {
                    Scaffold.of(context).showSnackBar(
                      SnackBar(
                        content: Text(counterService.error.message),
                      ),
                    );
                  }
                },
              );
            },
            icon: Icon(
              Icons.add_circle,
              color: Theme.of(context).primaryColor,
            ),
            iconSize: 40,
          ),
        ],
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
      ),
      // Decoration of the Container
      height: 100,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(
          width: 2,
          color: Theme.of(context).primaryColor,
        ),
      ),
      margin: EdgeInsets.all(1),
    );
  }
}
```