// You didn’t create a repository interface for the Brand entity simply because there is no requirement
// to obtain a Brand entity outside of a Product, unlike the Category entity. If you were looking at a
// Brand entity from a different context, such as a product merchandiser whose job it was to add product brands to the site, then the Brand would become an aggregate root, but in this context, you have
// no need to obtain Brands independently of Products.
import '../entity_base.dart';
import 'i_product_attribute.dart';

class Brand extends EntityBase<int> implements IProductAttribute {
  Brand(int id, String name) {
    this.id = id;
    this.name = name;
  } 
  
  @override
  String name;
  
  @override
  void validate() {
    print("implement invalidate : $runtimeType");
  }


}

abstract class BrandDbString {
  String tableName;
  String id;
  String name;
}
