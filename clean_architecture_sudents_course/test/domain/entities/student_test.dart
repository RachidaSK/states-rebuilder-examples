import 'package:clean_architecture_sudents_course/domain/entities/course.dart';
import 'package:clean_architecture_sudents_course/domain/entities/student.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'Cannot Register For Course Within 5 Days Of StartDate',
    () {
      final student = Student();

      final course = Course(
        code: "BIOL-1507EL",
        name: "Biology II",
        startDate: DateTime.now().add(
          Duration(days: 4),
        ),
      );

      final result = student.registerForCourse(course);

      expect(result, isFalse);
    },
  );

  test(
    'Cannot Register For Course already enrolled in',
    () {
      final student = Student()
        ..enrolledCourses.add(Course(code: "BIOL-1507EL", name: "Biology II"));

      final course = Course(code: "BIOL-1507EL", name: "Biology II");

      final result = student.registerForCourse(course);

      expect(result, isFalse);
    },
  );
}
