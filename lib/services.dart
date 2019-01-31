import './counter.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import './model/pm.dart';
import './model/commodities_others.dart';

class HttpQuotesServices {
  Future<ManagedObject> getMetalPriceValues(String typeOfProduct) async {
    RegExp productPriceSectionRE,
        actualPriceRE,
        shortTimeRE,
        longTimeRE,
        yrHighPriceSectionRE,
        yrLowPriceSectionRE;

    int i = 0;
    Map priceMap;
    ManagedObject managedObjectValues;

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
    Match productPriceSectionMatches;

    productPriceSectionRE = new RegExp(
      r'<div id="quotes_summary_current_data"[\s\S]+?<div class="float_lang_base_2',
      caseSensitive: false,
    );

    if (typeOfProduct == 'Gold') {
      response = await http.get('https://www.kitco.com/');

      //response = await http.get('http://www.goldseek.com/');

      //Live Gold Price[\s\S]+?</html>
      productPriceSectionRE = new RegExp(
        r'\<\!\-\- LIVE SPOT GOLD \-\-\>[\s\S]+?\<\!\-\- SILVER \& PGMS \-\-\>',
        caseSensitive: false,
      );
    }

    if (typeOfProduct == 'Silver') {
      response = await http.get('http://www.kitcosilver.com/');

      //response = await http.get('http://www.goldseek.com/');

      //Live Silver Price[\s\S]+?</html>
      productPriceSectionRE = new RegExp(
        r'Live Spot Silver Price[\s\S]+?\<\!\-\- BEGIN KITCO 10am FIX \-\-\>',
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

    productPriceSectionMatches =
        productPriceSectionRE.firstMatch(response.body);

    //print(productPriceSectionMatches.group(0));

    priceMatches =
        actualPriceRE.allMatches(productPriceSectionMatches.group(0));

    if (typeOfProduct == 'Gold' || typeOfProduct == 'Silver') {
      if (typeOfProduct == 'Gold') {
        longTime = 'None';
      } else {
        longTimeRE = new RegExp(r"\w{3}\s+\d+\s+\d{4}\s+\d+:\d{2}\s*[A|P]M");
        longTime = longTimeRE
            .firstMatch(productPriceSectionMatches.group(0))
            ?.group(0);
      }

      //longTimeRE = new RegExp(r"\S\S\S \d\d, \d\d\d\d \d\d:\d\d:\d\d E\ST");
      //longTime = longTimeRE.firstMatch(productPriceSectionMatches.group(0))?.group(0);

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
      if (typeOfProduct == 'Gold') {
        response = await http
            .get('https://www.bullionbypost.co.uk/gold-price/year/ounces/USD/');
      } else {
        response = await http
            .get('https://www.bullionbypost.co.uk/silver-price/year/ounces/USD/');
      }

      yrHighPriceSectionRE = new RegExp(
        r'Year High\"[\s\S]+?</span></td>',
        caseSensitive: false,
      );

      yrLowPriceSectionRE = new RegExp(
        r'Year Low\"[\s\S]+?</span></td>',
        caseSensitive: false,
      );

      productPriceSectionMatches =
          yrHighPriceSectionRE.firstMatch(response.body);

      year1HighPrice = actualPriceRE
          .firstMatch(productPriceSectionMatches.group(0))
          ?.group(0);

      productPriceSectionMatches =
          yrLowPriceSectionRE.firstMatch(response.body);

      year1LowPrice = actualPriceRE
          .firstMatch(productPriceSectionMatches.group(0))
          ?.group(0);

      priceMap = {
        "bidask": "$bidPrice | $askPrice",
        "lowhigh": "$lowPrice | $highPrice",
        "change": "$changeValue | $changePercentage",
        "1month": "$month1ChangeValue | $month1ChangePercentage",
        "1year": "$year1ChangeValue | $year1ChangePercentage",
        "yearlowhigh": "$year1LowPrice | $year1HighPrice",
        "time": "$longTime",
      };

      managedObjectValues = PMQuotes()
        ..pmtype = typeOfProduct
        ..bid = bidPrice
        ..ask = askPrice
        ..low = lowPrice
        ..high = highPrice
        ..changeValue = changeValue
        ..changePercentage = changePercentage
        ..month1ChangeValue = month1ChangeValue
        ..month1ChangePercentage = month1ChangePercentage
        ..year1ChangeValue = year1ChangeValue
        ..year1ChangePercentage = year1ChangePercentage
        ..year1LowPrice = year1LowPrice
        ..year1HighPrice = year1HighPrice
        ..longTime = longTime
        ..quoteJson = Document(priceMap);
    } else {
      shortTimeRE = new RegExp(r"\d\d:\d\d:\d\d");
      shortTime =
          shortTimeRE.firstMatch(productPriceSectionMatches.group(0))?.group(0);
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
        "time": "$shortTime",
      };

      managedObjectValues = CommoditiesOthers()
        ..commoditytype = typeOfProduct
        ..price = currentPrice
        ..changeValue = changeValue
        ..changePercentage = changePercentage
        ..lowPrice = lowPrice
        ..highPrice = highPrice
        ..shortTime = shortTime
        ..quoteJson = Document(priceMap);
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
    return managedObjectValues;
  }
}
