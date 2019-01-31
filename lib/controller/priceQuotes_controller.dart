import '../counter.dart';
import '../services.dart';
import '../model/pm.dart';
import '../model/commodities_others.dart';


class PriceQuotesController extends ResourceController {
  PriceQuotesController(this.context);

  final ManagedContext context;

  @Operation.get('productType')
  Future<Response> getCommodityPrice() async {
    final productType = request.path.variables["productType"];

    print("Inside getCommodityPrice Function.");

    if (productType == 'Gold' || productType == 'Silver') {
      final fetchedObject = await context.fetchObjectWithID<PMQuotes>(productType);
      return new Response.ok(fetchedObject.quoteJson.data);
    } else {
      final fetchedObject = await context.fetchObjectWithID<CommoditiesOthers>(productType);
      return new Response.ok(fetchedObject.quoteJson.data);
    }
  }
/*
  @Operation.get('productType')
  Future<Response> getGoldPrice() async {

    final productType = request.path.variables["productType"];

    HttpQuotesServices httpQuotesServices = new HttpQuotesServices();
    
    return new Response.ok(await httpQuotesServices.getMetalPriceValues(productType));

  }
*/
}
