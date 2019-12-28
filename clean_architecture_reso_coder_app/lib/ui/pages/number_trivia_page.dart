import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import '../../service/number_trivia_service.dart';
import '../exceptions/error_handler.dart';
import '../widgets/loading_widget.dart';
import '../widgets/message_display.dart';
import 'trivia_controls.dart';
import 'trivia_display.dart';

class NumberTriviaPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Number Trivia'),
      ),
      body: SingleChildScrollView(
        child: BuildBody(),
      ),
    );
  }
}

class BuildBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final numberTriviaService =
        Injector.getAsReactive<NumberTriviaService>(context: context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
            SizedBox(height: 10),
            // Top half
            Builder(
              builder: (context) {
                if (numberTriviaService.isIdle) {
                  return MessageDisplay(message: 'Start searching!');
                } else if (numberTriviaService.isWaiting) {
                  return LoadingWidget();
                } else if (numberTriviaService.hasError) {
                  return MessageDisplay(
                    message:
                        ErrorHandler.errorMessage(numberTriviaService.error),
                  );
                }
                return TriviaDisplay();
              },
            ),
            SizedBox(height: 20),
            // Bottom half
            TriviaControls()
          ],
        ),
      ),
    );
  }
}
