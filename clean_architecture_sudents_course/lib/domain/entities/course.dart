import 'i_entity_base.dart';

class Course extends IEntityBase {
  final String code;
  final String name;
  final String description;
  final DateTime startDate;
  final DateTime endDate;

  Course(
      {int id,
      this.code,
      this.name,
      this.description,
      this.startDate,
      this.endDate})
      : super(id);
}
