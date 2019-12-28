import 'package:meta/meta.dart';

class NumberTrivia {
  String text;
  int number;

  NumberTrivia({
    @required this.text,
    @required this.number,
  });

  factory NumberTrivia.fromJson(Map<String, dynamic> json) {
    return NumberTrivia(
      text: json['text'],
      number: (json['number'] as num).toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'number': number,
    };
  }
}
