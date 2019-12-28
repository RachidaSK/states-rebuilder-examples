# countdown_timer

In this example, we will build a countdown timer.

The countdown timer has three status:
1. ready status : The initial time is displayed with a play button. 
2. running status : The time is ticking down each second with two buttons to pause and replay the timer.
3. paused status : The timer is paused with two buttons to resume and stop the timer

The source of the timer is a dart stream defined in the `TimerModel` class : 

# Business logic part:
```dart
class TimerModel {
  TimerModel(this.initialTime);

  int initialTime;

  getTimerStream() {
    return Stream.periodic(
      Duration(seconds: 1),
      (num) => num,
    );
  }
}
```
The `initialTime` defines the time to start from, and the `getTimerStream` is stream of one second increasing integers.

The next step is to define an enumeration to define that status of the timer:

```dart
enum TimerStatus { ready, running, paused }
```

Again with states_rebuilder no matter how complicated your logic is, it remains a pure dart class.

# The user interface part:

```dart
import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

void main() => runApp(MaterialApp(home: App()));


class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Countdown Timer')),
      body: Injector(
        inject: [
          //NOTE1 : Injecting the TimerModel with initial time of 60 seconds
          Inject(
            () => TimerModel(60),
            //NOTE2: define the initial customStateStatus of the TimerModel
            initialCustomStateStatus: TimerStatus.ready,
          )
        ],
        builder: (context) {
          return TimerView();
        },
      ),
    );
  }
}
```

As always, The first thing to think about is to inject your model in the widget tree [NOTE1].

with states_rebuilder your models are pure dart classes. It is when obtaining an injected model, that reactivity is implicitly added to your pure dart model. 

Among the getters that are added to the reactive environment are the getters `connectionState` and `hasError`:

`connectionState` define there status the reactive environment can have:
1. `ConnectionState.none` : for verging environment: That is before calling any method of the model:
2. `ConnectionState.waiting` : while waiting for an asynchronous task to complete 
3. `ConnectionState.done` : after the asynchronous task is finished.

`hasError` : is boolean, that is true if the  called method throws an error.

`connectionState` and `hasError` are set automatically by states_rebuilder, and your role is limited to use them in your UI to display the corresponding view.

states_rebuilder give you the ability to define custom state status other the those defined by `connectionState` and `hasError`. The field `customStateStatus` is here for this purpose.

In our example we want the `customStateStatus` to take one of the three value defined by the enumeration `TimerStatus`.

To define an initial value of the `customStateStatus` that the app starts with, we use the parameter  `initialCustomStateStatus` of the `Inject` [NOTE2]. We set `initialCustomStateStatus`  to `TimerStatus.ready` because we want our app to start with the ready status.

Let's continue by defining the `TimerView` widget:

```dart
class TimerView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //NOTE1 : Getting the registered reactive singleton of the TimerModel
    //NOTE1 : The context is defined so that it will be subscribed to the TimerModel.
    final timerModel = Injector.getAsReactive<TimerModel>(context: context);

    //NOTE2 : Local variable to hold the current timer value.
    int duration;

    return Injector(
      //NOTE3 : Defining the a unique key of the widget. 
      key: UniqueKey(),
      //NOTE4: Injecting the stream
      inject: [
        Inject<int>.stream(
          () => timerModel.state.getTimerStream(),

          //NOTE4 : Defining the initialValue of the stream
          initialValue: timerModel.state.initialTime,
        ),
      ],
      builder: (context) {

        //NOTE5 : Getting the registered reactive singleton of the stream using the 'int' type.
        final timerStream = Injector.getAsReactive<int>();

        return StateBuilder(
         // NOTE6 : Subscribe this StateBuilder to the timerStream reactive singleton
          models: [timerStream],
          //NOTE7 : defining the onSetState callback to be called when this StateBuilder is notified and before the trigger of the rebuilding process.
          onSetState: (_, __) {
            //NOTE8 : Decrement the duration each time the stream emits a value
            duration =
                timerModel.state.initialTime - timerStream.snapshot.data - 1;
            //NOTE8 : Check if duration reaches zero and set the customStateStatus to be equal to TimerStatus.ready
            if (duration <= 0) {
              timerModel.setState(
                (state) {
                  timerModel.customStateStatus = TimerStatus.ready;
                },
              );
            }
          },
          builder: (context, __) {
            return Center(
              child: Row(
                children: <Widget>[
                  Expanded(
                    //NOTE9 : Widget to display a formatted string of the duration.
                    child: TimerDigit(
                      duration ?? timerModel.state.initialTime,
                    ),
                  ),
                  Expanded(
                    //NOTE10 : define another StateBuilder
                    child: StateBuilder(
                      //NOTE10: subscribe this StateBuilder to the timerModel
                      models: [timerModel],
                      //NOTE11 : Give it a tag so that we can control its notification
                      tag: 'timer',
                      builder: (context, timerService) {
                        //NOTE12 : Display the ReadyStatus widget if the customStateStatus is in the ready status
                        if (timerService.customStateStatus ==
                            TimerStatus.ready) {
                          timerStream.subscription.pause();
                          return ReadyStatus(
                            timerStream: timerStream,
                            timerService: timerService,
                          );
                        }
                        //NOTE13 : Display the RunningStatus widget if the customStateStatus is in the running status
                        if (timerService.customStateStatus ==
                            TimerStatus.running) {
                          return RunningStatus(
                            timerStream: timerStream,
                            timerService: timerService,
                          );
                        }
                        //NOTE14 : Display the PausedStatus widget if the customStateStatus is in the paused status
                        return PausedStatus(
                          timerStream: timerStream,
                          timerService: timerService,
                        );
                      },
                    ),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }
}
```

First of all, we get the registered reactive singleton of the `TimerModel` using `Injector.getAsReactive` model with the context defined. The widget of the defined context is subscribed to the `TimerModel` [NOTE1].

The next step is to inject the stream using `Inject.stream` [NOTE4] and set its initial value to be equal to `initialTime` of the `TimerModel`. 

Noticed that we set the key parameter of the `Injector` widget used to inject the stream to be `UniqueKey()` [NOTE3]. This is a concept related to Flutter. 

`Injector` is a statefulWidget, this means that when it is first created its state life starts by calling its `initState` method then the `build` method which is called each time the `State.setState` method is called or if any of its parent rebuilds. When `Injector` is removed from the widget tree, the `dispose` method is invoked. (There are some other intermediate life cycle methods not related to our case. For more information see this [article](https://flutterbyexample.com/stateful-widget-lifecycle/).

By setting the key parameter of the `Injector` to `UniqueKey()`, The `Injector` state will be dispose and created again if any of its parent widget rebuilds. This is useful for us, because states_rebuilder creates the injected stream in the `ìntState` and close and dispose of it in the `dispose` method. 

In our case, when the registered reactive singleton of the `TimerModel` triggers a notification without tag filter. the build method of `TimerView` will be called. At this stage, because we define the key to be unique, the injected stream is stopped and dispose, and a new stream is created and start emitting new set of values. (This is what will be used in the repay button).

Now that we has injected the stream using `Inject.stream`, we get the registered reactive singleton of the stream using `Injector.getAsReactive` method [NOTE5]. You use the type `int` to get the registered stream because it is injected with this type [NOTE4]. 

We have the option to inject the stream using a custom name, something like this :

```dart
Injector(
    key: UniqueKey(),
    inject: [
    Inject<int>.stream(
        () => timerModel.state.getTimerStream(),
        initialValue: timerModel.state.initialTime,
        name : 'customStreamName',
    ),
    ],
)
```

to get the reactive singleton :

```dart
final timerStream = Injector.getAsReactive<int>(name: 'customStreamName');
```

After getting the reactive singleton of the stream we subscribe to it using `StateBuilder` [NOTE6].

The stream emits each second a series of integer number starting from 0 then 1, 2, 3 , 4 ... and so on.

But we want the timer to start from an initial value and count down until it reaches zero. Something like this (60, 59, 58, ... until 0).

The appropriate place to do such a transformation is in the `onSetState` callback [NOTE7].

```dart
onSetState: (_, __) {
    //NOTE8 : Decrement the duration each time the stream emits a value
    duration =
        timerModel.state.initialTime - timerStream.snapshot.data - 1;
    //NOTE8 : Check if duration reaches zero and set the customStateStatus to be equal to TimerStatus.ready
    if (duration <= 0) {
        timerModel.setState(
        (state) {
            timerModel.customStateStatus = TimerStatus.ready;
        },
        );
    }
},
```

The `onSetState` callback is called each time the stream emits a value and before building the widget. After decrementing the duration we check if it reaches zero and set the `timerModel.customStateStatus` to be `TimerStatus.ready` and send notification to all subscribe widget. In our case The `TimerView` widget is subscribed to the `timerModel` so it will be notified to rebuild. At this stage, because we define the key to be unique, the injected stream is stopped and dispose, and a new stream is created and start emitting new set of values [NOTE3, NOTE4].

the `duration` value is passed to the `TimerDigit` widget to display a formated value (minutes : seconds) : [NOTE9]

```dart
class TimerDigit extends StatelessWidget {
  final int duration;
  TimerDigit(this.duration);
  String get minutesStr =>
      ((duration / 60) % 60).floor().toString().padLeft(2, '0');
  String get secondsStr => (duration % 60).floor().toString().padLeft(2, '0');
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.0),
      child: Center(
        child: Text(
          '$minutesStr:$secondsStr',
          style: TextStyle(
            fontSize: 60,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
```
To display the control buttons, we wrap them in `StateBuilder` that subscribe to `timerModel` reactive singleton with a tag of 'timer': [NOTE10 , NOTE11].

The reactive singleton `timerModel` has two Widgets subscribed to it:
* `TimerView` subscribed using the `BuildContext` [NOTE1];
* `StateBuilder` subscribed with a tag [NOTE10].

Whenever `timerModel` sends notification without tag both widgets will rebuild. And as discussed above, the `Injector` of the stream has a unique key [NOTE3] so the stream is closed and a new stream is created. We used this in [NOTE8] when the timer reaches zero. (Another use is in the replay action)

In contrast when `timerModel` sends notification with 'timer' tag only the StateBuilder subscribed with this tag will rebuild and the stream is not closed. (Used in the pause and resume actions).

The last thing is to display corresponding buttons for each `customStateStatus` :

1. **Ready status** : In [NOTE12] we check if the `customStateStatus` is ready and display the `ReadyStatus` widget after stopping the stream using the `subscription` getter of `timerStream` reactive singleton.

```dart
     timerStream.subscription.pause();
```
`ReadyStatus` looks like this :

```dart
class ReadyStatus extends StatelessWidget {
  const ReadyStatus({
    Key key,
    @required this.timerStream,
    @required this.timerService,
  }) : super(key: key);

  final ReactiveModel<int> timerStream;
  final ReactiveModel<TimerModel> timerService;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      child: Icon(Icons.play_arrow),
      heroTag: UniqueKey().toString(),
      onPressed: () {
        timerService.setState(
          (state) {
            timerService.customStateStatus = TimerStatus.running;
          },
          filterTags: ['timer'],
          onSetState: (context) {
            timerStream.subscription.resume();
          },
        );
      },
    );
  }
}
```

It a `FloatingActionButton` with play arrow icon. When the FAB is pressed, we set `timerService.customStateStatus` to `TimerStatus.running` and notify listener with 'timer' tag. In `onSetState` callback we resume the stream.

2.  **Running status** :  In [NOTE13] we check if the `customStateStatus` is running and display the `RunningStatus` widget: 

```dart
class RunningStatus extends StatelessWidget {
  const RunningStatus({
    Key key,
    @required this.timerStream,
    @required this.timerService,
  }) : super(key: key);

  final ReactiveModel<int> timerStream;
  final ReactiveModel<TimerModel> timerService;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        FloatingActionButton(
          child: Icon(Icons.pause),
          heroTag: UniqueKey().toString(),
          onPressed: () {
            timerService.setState(
              (state) {
                timerService.customStateStatus = TimerStatus.paused;
              },
              filterTags: ['timer'],
              onSetState: (context) {
                timerStream.subscription.pause();
              },
            );
          },
        ),
        FloatingActionButton(
          child: Icon(Icons.repeat),
          heroTag: UniqueKey().toString(),
          onPressed: () {
            timerService.setState(
              (state) {
                timerService.customStateStatus = TimerStatus.running;
              },
            );
          },
        ),
      ],
    );
  }
}
```

It consists of two FAB, one for pause and the other for repeat (replay) : 
* If the pause FAB is pressed, we set `timerService.customStateStatus` to `TimerStatus.paused` and notify listener with 'timer' tag. In `onSetState` callback we pause the stream.
* If the repeat FAB is pressed, we set `timerService.customStateStatus` to `TimerStatus.running` and notify listener with without tag so that the stream is closed and a brand new stream is created.

3. **Paused status** :  In [NOTE14] the `customStateStatus` because it is not ready nor running, so we will display the `PausedStatus` widget: 

```dart
class PausedStatus extends StatelessWidget {
  const PausedStatus({
    Key key,
    @required this.timerStream,
    @required this.timerService,
  }) : super(key: key);

  final ReactiveModel<int> timerStream;
  final ReactiveModel<TimerModel> timerService;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        FloatingActionButton(
          child: Icon(Icons.play_arrow),
          heroTag: UniqueKey().toString(),
          onPressed: () {
            timerService.setState(
              (state) {
                timerService.customStateStatus = TimerStatus.running;
              },
              filterTags: ['timer'],
              onSetState: (context) {
                timerStream.subscription.resume();
              },
            );
          },
        ),
        FloatingActionButton(
          child: Icon(Icons.stop),
          heroTag: UniqueKey().toString(),
          onPressed: () {
            timerService.setState(
              (state) {
                timerService.customStateStatus = TimerStatus.ready;
              },
            );
          },
        ),
      ],
    );
  }
}
```

It consists of two FAB, one for resume and the other for stop : 
* If the pause FAB is resume, we set `timerService.customStateStatus` to `TimerStatus.running` and notify listener with 'timer' tag. In `onSetState` callback we resume the stream.
* If the stop FAB is pressed, we set `timerService.customStateStatus` to `TimerStatus.ready` and notify listener with without tag so that the stream is closed and a brand new stream is created.