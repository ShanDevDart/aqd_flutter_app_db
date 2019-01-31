import '../counter.dart';

class PMQuotes extends ManagedObject<_PMQuotes> implements _PMQuotes {

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

class _PMQuotes {

  @Column(primaryKey: true)
  String pmtype;

  String bid;
  String ask;
  String low;
  String high;
  String changeValue;
  String changePercentage;
  String month1ChangeValue;
  String month1ChangePercentage;
  String year1ChangeValue;
  String year1ChangePercentage;
  String year1LowPrice;
  String year1HighPrice;
  String longTime;

  Document quoteJson;

  @Column(indexed: true)
  DateTime createdAt;

  @Column(indexed: true)
  DateTime updatedAt;
}

/*
  PMQuotes.fromJson(Map<String, dynamic> json)
      : bid = json['bidask'],
        ask = json['bidask'],
        low = json['lowhigh'],
        high = json['lowhigh'],
        changeValue = json['change'],
        changePercentage = json['change'],
        month1ChangeValue = json['1month'],
        month1ChangePercentage = json['1month'],
        year1ChangeValue = json['1year'],
        year1ChangePercentage = json['1year'],
        year1LowPrice = json['yearlowhigh'],
        year1HighPrice = json['yearlowhigh'],
        longTime = json['time'];

final String bid;
final String ask;
final String low;
final String high;
final String changeValue;
final String changePercentage;
final String month1ChangeValue ;
final String month1ChangePercentage;
final String year1ChangeValue;
final String year1ChangePercentage;
final String year1LowPrice;
final String year1HighPrice;
final String longTime;
*/