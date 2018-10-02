import 'dart:async';
import 'package:http/http.dart' as http;

class HttpQuotesServices {
  Future<Map> getMetalPrice(String typeOfProduct) async {
    RegExp productPriceSectionRE, actualPriceRE, shortTimeRE, longTimeRE;

    int i = 0;
    Map priceMap;

    String currentPrice,
        bidPrice,
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
        year1HighPrice,
        shortTime,
        longTime;

    http.Response response;

    Iterable<Match> priceMatches;

    productPriceSectionRE = new RegExp(
      r'<div id="quotes_summary_current_data"[\s\S]+?<div class="float_lang_base_2',
      caseSensitive: false,
    );

    if (typeOfProduct == 'Gold' || typeOfProduct == 'Silver') {
      response = await http.get('http://www.goldseek.com/');
      typeOfProduct == 'Gold'
          ? productPriceSectionRE = new RegExp(
              r'Live Gold Price[\s\S]+?</html>',
              caseSensitive: false,
            )
          : productPriceSectionRE = new RegExp(
              r'Live Silver Price[\s\S]+?</html>',
              caseSensitive: false,
            );
    }

    if (typeOfProduct == 'BitCoin') {
      response =
          await http.get('https://www.investing.com/crypto/bitcoin/btc-usd');
    }

    if (typeOfProduct == 'CrudeOil') {
      response =
          await http.get('https://www.investing.com/commodities/crude-oil');
    }

    if (typeOfProduct == 'USD') {
      response = await http.get('https://www.investing.com/indices/usdollar');
    }

    actualPriceRE = new RegExp(
      r"[\+|\-|\$]*[\d\,]*\d+\.\d{1,2}[\%]*",
      caseSensitive: false,
    );

    Match productPriceSectionMatches =
        productPriceSectionRE.firstMatch(response.body);

    priceMatches =
        actualPriceRE.allMatches(productPriceSectionMatches.group(0));

    if (typeOfProduct == 'Gold' || typeOfProduct == 'Silver') {
      longTimeRE = new RegExp(r"\S\S\S \d\d, \d\d\d\d \d\d:\d\d:\d\d E\ST");
      longTime = longTimeRE.firstMatch(productPriceSectionMatches.group(0))?.group(0);

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

      priceMap = {
        "bidask": "$bidPrice | $askPrice",
        "lowhigh": "$lowPrice | $highPrice",
        "change": "$changeValue | $changePercentage",
        "1month": "$month1ChangeValue | $month1ChangePercentage",
        "1year": "$year1ChangeValue | $year1ChangePercentage",
        "yearlowhigh": "$year1LowPrice | $year1HighPrice",
        "time" : "$longTime",
      };
    } else {
      shortTimeRE = new RegExp(r"\d\d:\d\d:\d\d");
      shortTime = shortTimeRE.firstMatch(productPriceSectionMatches.group(0))?.group(0);
      //shortTime = tmpShortTime.group(0);

      for (Match price in priceMatches) {
        if (i == 0) {
          currentPrice = price.group(0);
        }
        if (i == 1) {
          changeValue = price.group(0);
        }
        if (i == 2) {
          changePercentage = price.group(0);
        }
        if (i == (priceMatches.length - 2)) {
          lowPrice = price.group(0);
        }
        if (i == (priceMatches.length - 1)) {
          highPrice = price.group(0);
        }
        i++;
      }

      priceMap = {
        "price": "$currentPrice",
        "change": "$changeValue | $changePercentage",
        "lowhigh": "$lowPrice | $highPrice",
        "time" : "$shortTime",
      };
    }
/*
    if (typeOfProduct == 'Gold' || typeOfProduct == 'Silver') {
      print("Bid|Ask : $bidPrice | $askPrice");
      print("Low|High : $lowPrice | $highPrice");
      print("Change : $changeValue | $changePercentage");
      print("1 Month : $month1ChangeValue | $month1ChangePercentage");
      print("1 year : $year1ChangeValue | $year1ChangePercentage");
      print("Year Low|High : $year1LowPrice | $year1HighPrice");
      print("Time : $longTime");
    } else {
      print("Price : $currentPrice");
      print("Change : $changeValue | $changePercentage");
      print("Low|High : $lowPrice | $highPrice");
      print("Time : $shortTime");
    }
*/
    return priceMap;
  }
}
