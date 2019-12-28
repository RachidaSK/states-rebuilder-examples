import 'i_domain_event_base.dart';

abstract class IEntityBase {
  final int id;
  final List<DomainEventBase> events = [];

  IEntityBase(this.id);
}
