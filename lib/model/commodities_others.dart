import '../counter.dart';

class CommoditiesOthers extends ManagedObject<_CommoditiesOthers> implements _CommoditiesOthers {
  @override
  void willUpdate() {
    updatedAt = new DateTime.now().toUtc();
  }

  @override
  void willInsert() {
    createdAt = new DateTime.now().toUtc();
    updatedAt = new DateTime.now().toUtc();
  }
}

class _CommoditiesOthers {
  @Column(primaryKey: true)
  String commoditytype;

  String price;
  String changeValue;
  String changePercentage;
  String lowPrice;
  String highPrice;
  String shortTime;

  Document quoteJson;

  @Column(indexed: true)
  DateTime createdAt;

  @Column(indexed: true)
  DateTime updatedAt;

}
