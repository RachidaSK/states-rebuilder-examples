import '../../domain/entities/student.dart';

abstract class IStudentRepository {
  Student getById(int id);
  void save(Student student);
}
