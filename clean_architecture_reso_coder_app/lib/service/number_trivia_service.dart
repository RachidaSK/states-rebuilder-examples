import 'package:meta/meta.dart';

import '../domain/entities/number_trivia.dart';
import 'input_converter.dart';
import 'interfaces/number_trivia_repository.dart';

class NumberTriviaService {
  NumberTriviaService({
    @required this.numberTriviaRepository,
    @required this.inputConverter,
  })  : assert(numberTriviaRepository != null),
        assert(inputConverter != null);
  final NumberTriviaRepository numberTriviaRepository;
  final InputConverter inputConverter;

  NumberTrivia trivia;

  Future<void> getTriviaForConcreteNumber(String numberString) async {
    final input = inputConverter.stringToUnsignedInteger(numberString);
    trivia = await numberTriviaRepository.getConcreteNumberTrivia(input);
  }

  Future<void> getTriviaForRandomNumber() async {
    trivia = await numberTriviaRepository.getRandomNumberTrivia();
  }
}
