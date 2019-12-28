import 'course.dart';
import 'i_entity_base.dart';

class Student extends IEntityBase {
  final String firstName;
  final String lastName;

  final List<Course> registeredCourses = [];
  final List<Course> enrolledCourses = [];

  Student({int id, this.firstName, this.lastName}) : super(id);

  bool registerForCourse(Course course) {
    // student has not previously enrolled
    if (enrolledCourses.any((ec) => ec.code == course.code)) return false;

    // student has not previously registered
    if (registeredCourses.any((ec) => ec.code == course.code)) return false;

    // registratraion cannot occur with 5 days of course start date
    print(DateTime.now().day);
    print(course.startDate.add(Duration(days: -5)).day);
    if (DateTime.now().day > course.startDate.add(Duration(days: -5)).day)
      return false;

    registeredCourses.add(course);
    return true;
  }
}
