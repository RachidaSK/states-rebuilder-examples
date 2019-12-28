import 'interfaces/i_auth_service.dart';
import 'interfaces/i_course_repository.dart';
import 'interfaces/i_request_handler.dart';
import 'interfaces/i_student_repository.dart';
import 'mediator/course_registration_request_message.dart';
import 'mediator/course_registration_response_message.dart';

class CourseRegistration extends IRequestHandler<
    CourseRegistrationRequestMessage, CourseRegistrationResponseMessage> {
  CourseRegistration({
    this.studentRepository,
    this.courseRepository,
    this.authService,
  });

  final IStudentRepository studentRepository;
  final ICourseRepository courseRepository;
  final IAuthService authService;

  @override
  CourseRegistrationResponseMessage handle(
      CourseRegistrationRequestMessage message) {
    // student must be logged into system
    if (!authService.isAuthenticated()) {
      return new CourseRegistrationResponseMessage(
        false,
        null,
        "Operation failed, not authenticated.",
      );
    }
    // get the student
    var student = studentRepository.getById(message.studentId);

    // save off any failures
    List<String> errors = [];

    for (var c in message.selectedCourseCodes) {
      var course = courseRepository.getByCode(c);

      if (!student.registerForCourse(course)) {
        errors.add("unable to register for ${course.code}");
      }
    }

    studentRepository.save(student);

    return new CourseRegistrationResponseMessage(errors.isEmpty, errors, '');
  }
}
