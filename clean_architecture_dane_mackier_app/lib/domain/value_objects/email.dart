import '../exceptions/email_exception.dart';

class Email {
  Email(String email) {
    if (email.contains('@')) {
      _email = email;
    } else {
      throw EmailException();
    }
  }

  String _email;
  String get email => _email;
}
