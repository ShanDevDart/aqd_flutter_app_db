import '../counter.dart';
import '../services.dart';

class PriceQuotesController extends ResourceController {

  @Operation.get('productType')
  Future<Response> getGoldPrice() async {

    final productType = request.path.variables["productType"];

    HttpQuotesServices httpQuotesServices = new HttpQuotesServices();
    
    return new Response.ok(await httpQuotesServices.getMetalPrice(productType));

  }
}
