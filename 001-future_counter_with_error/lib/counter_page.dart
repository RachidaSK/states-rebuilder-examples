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
            Builder(
              builder: (BuildContext context) {
                if (counterService.isIdle) {
                  return Text(
                      'Top on the plus button to start incrementing the counter');
                }
                if (counterService.isWaiting) {
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
          ],
        ),
      ),
    );
  }
}
