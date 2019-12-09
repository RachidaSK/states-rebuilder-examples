import 'dart:async';

class LoginFormModel {
  final emailController = StreamController<String>();
  final passwordController = StreamController<String>();

  Function(String) get changeEmail => emailController.sink.add;
  Function(String) get changePassword => passwordController.sink.add;

  Stream<String> get email => emailController.stream.transform(validateEmail);
  Stream<String> get password =>
      passwordController.stream.transform(validatePassword);

  submit() {
    print("form submitted");
  }

  //The validation of the email. It must contain @
  final validateEmail = StreamTransformer<String, String>.fromHandlers(
    handleData: (email, sink) {
      if (email.contains("@")) {
        sink.add(email);
      } else {
        sink.addError("Enter a valid Email");
      }
    },
  );

  //The validation of the password. It must have more than three characters
  final validatePassword = StreamTransformer<String, String>.fromHandlers(
    handleData: (password, sink) {
      if (password.length > 3) {
        sink.add(password);
      } else {
        sink.addError("Enter a valid password");
      }
    },
  );

  //Disposing the controllers
  dispose() {
    emailController.close();
    passwordController.close();
    print("controllers are disposed");
  }
}
