import '../interfaces/i_response_message.dart';

class CourseRegistrationResponseMessage extends ResponseMessage {
  final List<String> errors;

  CourseRegistrationResponseMessage(bool success, this.errors, String message)
      : super(
          success: success,
          message: message,
        );
}
