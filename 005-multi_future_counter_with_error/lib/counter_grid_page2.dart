import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import 'counter_service.dart';

class CounterGridPage2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Injector(
      inject: [
        Inject(
          () => CounterService(),
          joinSingleton: JoinSingleton.withCombinedReactiveInstances,
        )
      ],
      builder: (BuildContext context) {
        final counterServiceSingletonRM =
            Injector.getAsReactive<CounterService>();
        return Scaffold(
          appBar: AppBar(
            title: StateBuilder(
              models: [counterServiceSingletonRM],
              tag: 'appBar',
              builder: (context, _) {
                if (counterServiceSingletonRM.connectionState ==
                    ConnectionState.waiting) {
                  return Row(
                    children: <Widget>[
                      Text(
                          '${counterServiceSingletonRM.joinSingletonToNewData}  '),
                      CircularProgressIndicator(
                        backgroundColor: Colors.white,
                      ),
                    ],
                  );
                }

                if (counterServiceSingletonRM.hasError) {
                  return Text(
                    'Some counters have ERROR',
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  );
                }

                if (counterServiceSingletonRM.hasData) {
                  return Text('All counters have data');
                }

                return Text('There are still counters waiting for you');
              },
            ),
          ),
          body: GridView.count(
            crossAxisCount: 2,
            childAspectRatio: 0.68,
            children: <Widget>[
              StateBuilder<CounterService>(
                builder: (context, counterService) {
                  return CounterApp(
                    counterService: counterService,
                    name: 'Counter 1',
                  );
                },
              ),
              StateBuilder<CounterService>(
                builder: (context, counterService) {
                  return CounterApp(
                    counterService: counterService,
                    name: 'Counter 2',
                  );
                },
              ),
              StateBuilder<CounterService>(
                builder: (context, counterService) {
                  return CounterApp(
                    counterService: counterService,
                    name: 'Counter 3',
                  );
                },
              ),
              StateBuilder<CounterService>(
                builder: (context, counterService) {
                  return CounterApp(
                    counterService: counterService,
                    name: 'Counter 4',
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class CounterApp extends StatelessWidget {
  const CounterApp({Key key, this.counterService, this.name}) : super(key: key);
  final ReactiveModel<CounterService> counterService;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: StateBuilder(
        models: [counterService],
        tag: 'appBar',
        builderWithChild: (context, snapshot, child) {
          return Theme(
            data: ThemeData(
              primarySwatch:
                  counterService.hasError ? Colors.red : Colors.lightBlue,
            ),
            child: child,
          );
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(name),
          ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CounterBox(
                counterService: counterService,
                seconds: 1,
                tag: 'blueCounter',
                color: Colors.blue,
                name: name,
              ),
              CounterBox(
                counterService: counterService,
                seconds: 3,
                tag: 'greenCounter',
                color: Colors.green,
                name: name,
              ),
            ],
          ),
        ),
      ),
      decoration: BoxDecoration(
        border: Border.all(
          width: 2,
          color: Colors.lightBlue,
        ),
      ),
    );
  }
}

class CounterBox extends StatelessWidget {
  CounterBox({
    this.seconds,
    this.counterService,
    this.tag,
    this.color,
    this.name,
  });
  final int seconds;
  final ReactiveModel<CounterService> counterService;
  final String tag;
  final Color color;
  final String name;
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          StateBuilder(
            models: [counterService],
            tag: tag,
            builder: (BuildContext context, _) {
              if (counterService.isIdle) {
                return Text('Top on the btn to increment the counter');
              }
              if (counterService.isWaiting) {
                return Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text('$seconds second(s) wait  '),
                      CircularProgressIndicator(),
                    ],
                  ),
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
                filterTags: [tag, 'appBar'],
                joinSingletonToNewData: () => name,
                onError: (BuildContext context, dynamic error) {
                  Scaffold.of(context).showSnackBar(
                    SnackBar(
                      content: Text(counterService.error.message),
                    ),
                  );
                },
              );
            },
            icon: Icon(
              Icons.add_circle,
              color: color,
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
          color: color,
        ),
      ),
      margin: EdgeInsets.all(5),
    );
  }
}
