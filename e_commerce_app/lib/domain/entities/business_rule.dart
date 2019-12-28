//To check the validity of a domain entity prior to persistence, you will create a simple business rule
//class to store a rule and related entity property. The class will populate a collection of broken rules
//before saving an entity.

class BusinessRule {
  String property;
  String rule;
  BusinessRule(this.property, this.rule);
}
