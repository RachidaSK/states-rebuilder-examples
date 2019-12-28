import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import 'timer_model.dart';

void main() => runApp(MaterialApp(home: App()));

enum TimerStatus { ready, running, paused }

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Countdown Timer')),
      body: Injector(
        inject: [
          Inject(
            () => TimerModel(60),
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

class TimerView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final timerModel = Injector.getAsReactive<TimerModel>(context: context);

    int duration;
    return Injector(
      key: UniqueKey(),
      inject: [
        Inject<int>.stream(
          () => timerModel.state.getTimerStream(),
          initialValue: timerModel.state.initialTime,
        ),
      ],
      builder: (context) {
        final timerStream = Injector.getAsReactive<int>();
        return StateBuilder(
          models: [timerStream],
          onSetState: (_, __) {
            duration =
                timerModel.state.initialTime - timerStream.snapshot.data - 1;
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
                    child: TimerDigit(
                      duration ?? timerModel.state.initialTime,
                    ),
                  ),
                  Expanded(
                    child: StateBuilder(
                      models: [timerModel],
                      tag: 'timer',
                      builder: (context, timerService) {
                        //Ready
                        if (timerService.customStateStatus ==
                            TimerStatus.ready) {
                          timerStream.subscription.pause();
                          return ReadyStatus(
                            timerStream: timerStream,
                            timerService: timerService,
                          );
                        }
                        //Running
                        if (timerService.customStateStatus ==
                            TimerStatus.running) {
                          return RunningStatus(
                            timerStream: timerStream,
                            timerService: timerService,
                          );
                        }
                        //paused
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
