import 'login_form_error.dart';

class LoginFormModel {
  String email;
  String password;

  void setEmail(String email) {
    //The validation of the email. It must contain @
    if (!email.contains("@")) {
      throw LoginError("Enter a valid Email");
    }
    this.email = email;
  }

  void setPassword(String password) {
    //The validation of the password. It must have more than three characters
    if (password.length <= 3) {
      throw LoginError('Enter a valid password');
    }
    this.password = password;
  }

  submit() {
    print("form submitted");
  }
}
