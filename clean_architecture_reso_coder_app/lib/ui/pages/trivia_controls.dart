import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import '../../service/number_trivia_service.dart';

class TriviaControls extends StatelessWidget {
  TriviaControls() {
    numberTriviaService.cleaner(() {
      controller.dispose();
      print('disposed');
    });
  }

  final controller = TextEditingController();

  final numberTriviaService = Injector.getAsReactive<NumberTriviaService>();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Input a number',
          ),
          onChanged: (value) {
            numberTriviaService.customStateStatus = value;
          },
        ),
        SizedBox(height: 10),
        Row(
          children: <Widget>[
            Expanded(
              child: RaisedButton(
                child: Text('Search'),
                color: Theme.of(context).accentColor,
                textTheme: ButtonTextTheme.primary,
                onPressed: () {
                  controller.clear();

                  numberTriviaService.setState(
                    (state) => state.getTriviaForConcreteNumber(
                        numberTriviaService.customStateStatus),
                  );
                },
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: RaisedButton(
                child: Text('Get random trivia'),
                onPressed: () {
                  controller.clear();
                  numberTriviaService.setState(
                    (state) => state.getTriviaForRandomNumber(),
                  );
                },
              ),
            ),
          ],
        )
      ],
    );
  }
}
