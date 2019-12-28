// import 'package:flutter/material.dart';
// import 'package:states_rebuilder/states_rebuilder.dart';

// import 'timer_service.dart';

// void main() => runApp(MaterialApp(home: App()));

// enum TimerStatus { ready, running, paused, done }

// class App extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Injector(
//       inject: [
//         Inject(
//           () => TimerService(),
//           initialCustomStateStatus: TimerStatus.ready,
//           joinSingleton: JoinSingleton.withNewReactiveInstance,
//         ),
//       ],
//       builder: (context) {
//         final timerServiceSingleton = Injector.getAsReactive<TimerService>();
//         return Scaffold(
//           appBar: AppBar(
//             title: StateBuilder(
//               models: [timerServiceSingleton],
//               tag: 'timer',
//               builder: (context, _) {
//                 return Text(
//                     '${timerServiceSingleton.joinSingletonToNewData ?? ""}');
//               },
//             ),
//           ),
//           body: Column(
//             children: <Widget>[
//               StateBuilder<TimerService>(
//                 builder: (context, timerService) {
//                   return TimerView(
//                     timerService: timerService,
//                     timerServiceSingleton: timerServiceSingleton,
//                     name: 'Timer 1',
//                   );
//                 },
//               ),
//               StateBuilder<TimerService>(
//                 builder: (context, timerService) {
//                   return TimerView(
//                     timerService: timerService,
//                     timerServiceSingleton: timerServiceSingleton,
//                     name: 'Timer 2',
//                   );
//                 },
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }

// class TimerView extends StatelessWidget {
//   const TimerView({
//     Key key,
//     @required this.timerService,
//     @required this.timerServiceSingleton,
//     @required this.name,
//   }) : super(key: key);

//   final ReactiveModel<TimerService> timerService;
//   final ReactiveModel<TimerService> timerServiceSingleton;
//   final String name;

//   @override
//   Widget build(BuildContext context) {
//     int duration = 60;
//     return Injector(
//       key: UniqueKey(),
//       inject: [
//         Inject<int>.stream(
//           () => timerService.state.getTimer(),
//           initialValue: 60,
//         ),
//       ],
//       builder: (context) {
//         final timerStream = Injector.getAsReactive<int>();
//         return StateBuilder(
//           models: [timerStream],
//           onSetState: (_, __) {
//             duration = 60 - timerStream.snapshot.data - 1;
//             if (duration <= 0) {
//               timerService.setState(
//                 (state) {
//                   timerService.customStateStatus = TimerStatus.ready;
//                 },
//               );
//             }
//           },
//           builder: (context, __) {
//             return StateBuilder(
//                 models: [timerService],
//                 tag: 'timer',
//                 onSetState: (_, __) {
//                   if (timerServiceSingleton.joinSingletonToNewData != name) {
//                     timerStream.subscription.pause();
//                     timerService.customStateStatus = TimerStatus.paused;
//                     // timerService.setState(
//                     //   (state) {
//                     //   },
//                     //   filterTags: ['timer'],
//                     // );
//                     // return;
//                   }
//                 },
//                 builder: (context, timerService) {
//                   return Container(
//                     margin: EdgeInsets.all(2),
//                     decoration: BoxDecoration(
//                       color:
//                           timerServiceSingleton.joinSingletonToNewData != name
//                               ? Colors.grey
//                               : Colors.white,
//                       border: Border.all(
//                         width: 2,
//                       ),
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: Row(
//                       children: <Widget>[
//                         Expanded(child: Center(child: TimerDigit(duration))),
//                         Expanded(
//                           child: Builder(
//                             builder: (context) {
//                               //Ready
//                               if (timerService.customStateStatus ==
//                                   TimerStatus.ready) {
//                                 timerStream.subscription.pause();
//                                 return ReadyStatus(
//                                   timerStream: timerStream,
//                                   timerService: timerService,
//                                   name: name,
//                                 );
//                               }
//                               //Running
//                               if (timerService.customStateStatus ==
//                                   TimerStatus.running) {
//                                 return RunningStatus(
//                                   timerStream: timerStream,
//                                   timerService: timerService,
//                                 );
//                               }
//                               //paused
//                               return PausedStatus(
//                                 timerStream: timerStream,
//                                 timerService: timerService,
//                                 name: name,
//                               );
//                             },
//                           ),
//                         )
//                       ],
//                     ),
//                   );
//                 });
//           },
//         );
//       },
//     );
//   }
// }

// class PausedStatus extends StatelessWidget {
//   const PausedStatus({
//     Key key,
//     @required this.timerStream,
//     @required this.timerService,
//     @required this.name,
//   }) : super(key: key);

//   final ReactiveModel<int> timerStream;
//   final ReactiveModel<TimerService> timerService;
//   final String name;

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceAround,
//       children: <Widget>[
//         FloatingActionButton(
//           child: Icon(Icons.play_arrow),
//           heroTag: UniqueKey().toString(),
//           elevation: 0,
//           onPressed: () {
//             timerService.setState(
//               (state) {
//                 timerService.customStateStatus = TimerStatus.running;
//                 timerService.joinSingletonToNewData = name;
//               },
//               filterTags: ['timer'],
//               notifyAllReactiveInstances: true,
//               onSetState: (context) {
//                 timerStream.subscription.resume();
//               },
//             );
//           },
//         ),
//         FloatingActionButton(
//           child: Icon(Icons.stop),
//           heroTag: UniqueKey().toString(),
//           elevation: 0,
//           onPressed: () {
//             timerService.setState(
//               (state) {
//                 timerService.customStateStatus = TimerStatus.ready;
//                 timerService.joinSingletonToNewData = name;
//               },
//             );
//           },
//         ),
//       ],
//     );
//   }
// }

// class RunningStatus extends StatelessWidget {
//   const RunningStatus({
//     Key key,
//     @required this.timerStream,
//     @required this.timerService,
//   }) : super(key: key);

//   final ReactiveModel<int> timerStream;
//   final ReactiveModel<TimerService> timerService;

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceAround,
//       children: <Widget>[
//         FloatingActionButton(
//           child: Icon(Icons.pause),
//           heroTag: UniqueKey().toString(),
//           elevation: 0,
//           onPressed: () {
//             timerService.setState(
//               (state) {
//                 timerService.customStateStatus = TimerStatus.paused;
//               },
//               filterTags: ['timer'],
//               notifyAllReactiveInstances: true,
//               onSetState: (context) {
//                 timerStream.subscription.pause();
//               },
//             );
//           },
//         ),
//         FloatingActionButton(
//           child: Icon(Icons.repeat),
//           heroTag: UniqueKey().toString(),
//           elevation: 0,
//           onPressed: () {
//             timerService.setState(
//               (state) {
//                 timerService.customStateStatus = TimerStatus.running;
//               },
//             );
//           },
//         ),
//       ],
//     );
//   }
// }

// class ReadyStatus extends StatelessWidget {
//   const ReadyStatus({
//     Key key,
//     @required this.timerStream,
//     @required this.timerService,
//     @required this.name,
//   }) : super(key: key);

//   final ReactiveModel<int> timerStream;
//   final ReactiveModel<TimerService> timerService;
//   final String name;

//   @override
//   Widget build(BuildContext context) {
//     return FloatingActionButton(
//       child: Icon(Icons.play_arrow),
//       heroTag: UniqueKey().toString(),
//       elevation: 0,
//       onPressed: () {
//         timerService.setState(
//           (state) {
//             timerService.customStateStatus = TimerStatus.running;
//             timerService.joinSingletonToNewData = name;
//           },
//           filterTags: ['timer'],
//           notifyAllReactiveInstances: true,
//           onSetState: (context) {
//             timerStream.subscription.resume();
//           },
//         );
//       },
//     );
//   }
// }

// class TimerDigit extends StatelessWidget {
//   final int duration;
//   TimerDigit(this.duration);
//   String get minutesStr =>
//       ((duration / 60) % 60).floor().toString().padLeft(2, '0');
//   String get secondsStr => (duration % 60).floor().toString().padLeft(2, '0');
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.symmetric(vertical: 0.0),
//       child: Center(
//         child: Text(
//           '$minutesStr:$secondsStr',
//           style: TextStyle(
//             fontSize: 60,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//     );
//   }
// }
