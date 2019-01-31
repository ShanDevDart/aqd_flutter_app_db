import '../counter.dart';
import '../model/pm.dart';
import '../model/commodities_others.dart';
import '../services.dart';
import 'dart:convert';

class UpdatePriceQuotesController extends ResourceController {
  UpdatePriceQuotesController(this.context);

  final ManagedContext context;

  @Operation.get()
  Future<Response> updateAllPrice() async {

    ManagedObject managedObjectValues;
    var query;
    List<PMQuotes> pmUpdatedRow;
    List<CommoditiesOthers> cooUpdatedRow;

    HttpQuotesServices httpQuotesServices = new HttpQuotesServices();
    
    managedObjectValues = await httpQuotesServices.getMetalPriceValues("Gold");
    query = Query<PMQuotes>(context) ..values = managedObjectValues ..where((pmq) => pmq.pmtype).equalTo("Gold");
    pmUpdatedRow = await query.update();

    managedObjectValues = await httpQuotesServices.getMetalPriceValues("Silver");
    query = Query<PMQuotes>(context) ..values = managedObjectValues ..where((pmq) => pmq.pmtype).equalTo("Silver");
    pmUpdatedRow = await query.update();

    managedObjectValues = await httpQuotesServices.getMetalPriceValues("BitCoin");
    query = Query<CommoditiesOthers>(context) ..values = managedObjectValues ..where((coo) => coo.commoditytype).equalTo("BitCoin");
    cooUpdatedRow = await query.update();

    managedObjectValues = await httpQuotesServices.getMetalPriceValues("CrudeOil");
    query = Query<CommoditiesOthers>(context) ..values = managedObjectValues ..where((coo) => coo.commoditytype).equalTo("CrudeOil");
    cooUpdatedRow = await query.update();

    managedObjectValues = await httpQuotesServices.getMetalPriceValues("USD");
    query = Query<CommoditiesOthers>(context) ..values = managedObjectValues ..where((coo) => coo.commoditytype).equalTo("USD");
    cooUpdatedRow = await query.update();

    //Map quoteMap = jsonDecode(priceJSON);
    //var quote = new PMQuotes.fromJson(quoteMap);
    //print('Quote Bid : ${quote.bid}');

/*
    var pricePM = new PMQuotes.fromJson(priceJSON);

    final pmValues = PMQuotes()
      ..pmtype = 'Gold'
      ..bid = priceJSON[''].
      ..ask = ''
      ..low = ''
      ..high = ''
      ..changeValue = ''
      ..changePercentage = ''
      ..month1ChangeValue = ''
      ..month1ChangePercentage = ''
      ..year1ChangeValue = ''
      ..year1ChangePercentage = ''
      ..year1LowPrice = ''
      ..year1HighPrice = ''
      ..longTime = ''
      ..quoteJson = Document({'Empty': 'Empty'});

    final pmQuery = Query<PMQuotes>(context)..values = pmValues;
    final pmvalues = await pmQuery.insert();

    final comValues = CommoditiesOthers()
      ..commoditytype = 'OIL'
      ..price = ''
      ..changeValue = ''
      ..changePercentage = ''
      ..lowPrice = ''
      ..highPrice = ''
      ..shortTime = ''
      ..quoteJson = Document({'Empty': 'Empty'});

    final comQuery = Query<CommoditiesOthers>(context)..values = comValues;
    await comQuery.insert();
*/
    return new Response.ok("Updated Successfuly !");
  }
}
