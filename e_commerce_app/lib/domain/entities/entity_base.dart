import 'business_rule.dart';

//Because all entities will share the same validation mechanism, you will create a Layer Supertype
//(as discussed in Chapter 5) that all your domain entities will inherit from and that will provide the
//1infrastructure for checking domain validity
abstract class EntityBase<T> {
  List<BusinessRule> _brokenRules = [];
  T id;
  void validate();

  List<BusinessRule> getBrokenRules() {
    _brokenRules.clear();
    validate();
    return _brokenRules;
  }

  void addBrokenRule(BusinessRule businessRule) {
    _brokenRules.add(businessRule);
  }

  @override
  bool operator ==(Object entity) => entity is EntityBase<T> && id == entity.id;

  @override
  int get hashCode => id.hashCode;
}
