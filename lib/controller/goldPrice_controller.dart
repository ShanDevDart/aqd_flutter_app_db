import '../counter.dart';
import 'package:http/http.dart' as http;

class GoldPriceController extends ResourceController {

  @Operation.get()
  Future<Response> getGoldPrice() async {
    http.Response response = await http.get('http://www.goldseek.com/');

    int i = 0;
    String bidPrice,
        askPrice,
        highPrice,
        lowPrice,
        changeValue,
        changePercentage,
        month1ChangeValue,
        month1ChangePercentage,
        year1ChangeValue,
        year1ChangePercentage,
        year1LowPrice,
        year1HighPrice;
    Iterable<Match> priceMatches;

    RegExp priceRE = new RegExp(
      r"[\+|\-|\$]*[\d\,]*\d+\.\d{1,2}[\%]*",
      caseSensitive: false,
    );

    RegExp goldePriceRE = new RegExp(
      r'Live Gold Price[\s\S]+?</html>',
      caseSensitive: false,
    );

    Match goldPriceMatches = goldePriceRE.firstMatch(response.body);

    priceMatches = priceRE.allMatches(goldPriceMatches.group(0));

    for (Match price in priceMatches) {
      if (i == 0) {
        bidPrice = price.group(0);
      }
      if (i == 1) {
        askPrice = price.group(0);
      }
      if (i == 2) {
        lowPrice = price.group(0);
      }
      if (i == 3) {
        highPrice = price.group(0);
      }
      if (i == 4) {
        changeValue = price.group(0);
      }
      if (i == 5) {
        changePercentage = price.group(0);
      }
      if (i == 6) {
        month1ChangeValue = price.group(0);
      }
      if (i == 7) {
        month1ChangePercentage = price.group(0);
      }
      if (i == 8) {
        year1ChangeValue = price.group(0);
      }
      if (i == 9) {
        year1ChangePercentage = price.group(0);
      }
      if (i == 10) {
        year1LowPrice = price.group(0);
      }
      if (i == 11) {
        year1HighPrice = price.group(0);
      }
      i++;
    }

    var priceResponse = {
      "bidask": "$bidPrice | $askPrice",
      "lowhigh": "$lowPrice | $highPrice",
      "change": "$changeValue | $changePercentage",
      "1month": "$month1ChangeValue | $month1ChangePercentage",
      "1year" : "$year1ChangeValue | $year1ChangePercentage",
      "yearlowhigh" : "$year1LowPrice | $year1HighPrice",
    };

    print("Bid|Ask : $bidPrice | $askPrice");
    print("Low|High : $lowPrice | $highPrice");
    print("Change : $changeValue | $changePercentage");
    print("1 Month : $month1ChangeValue | $month1ChangePercentage");
    print("1 year : $year1ChangeValue | $year1ChangePercentage");
    print("Year Low|High : $year1LowPrice | $year1HighPrice");

    return new Response.ok(priceResponse);
  }
}
