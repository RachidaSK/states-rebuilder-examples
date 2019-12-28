import '../../domain/entities/course.dart';

abstract class ICourseRepository {
  Course getByCode(String code);
  List<Course> getAll();
}
