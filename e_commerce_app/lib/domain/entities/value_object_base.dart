import 'business_rule.dart';

//Because value objects are immutable and cannot be changed, they will need to be created
//in a valid state. If a value object is not created in a valid state, an exception will
//be thrown.
//The ValueObjectBase class, as shown in the following listing, is very similar to the EntityBase
//class; expect that an exception will be thrown if it is invalid.

abstract class ValueObjectBase<T> {
  List<BusinessRule> _brokenRules = [];

  void validate();

  void throwExceptionIfInvalid() {
    _brokenRules.clear();
    validate();
    if (_brokenRules.length > 0) {
      String issues = "";
      for (BusinessRule businessRule in _brokenRules){
        issues += businessRule.rule + '\n';
      }
      throw new Exception(issues);
    }
  }

  List<BusinessRule> getBrokenRules() {
    _brokenRules.clear();
    validate();
    return _brokenRules;
  }

  void addBrokenRule(BusinessRule businessRule) {
    _brokenRules.add(businessRule);
  }
}
