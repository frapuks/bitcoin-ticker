import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:bitcoin_ticker/coin_data.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

String apiKey = '40945024-0845-4F06-9296-F67BEE85B58F';
String urlStart = 'https://rest.coinapi.io/v1/exchangerate';
String urlEnd = 'apikey=$apiKey';
String selectedCurrency = 'USD';

class PriceScreen extends StatefulWidget {
  const PriceScreen({super.key});

  @override
  PriceScreenState createState() => PriceScreenState();
}

class PriceScreenState extends State<PriceScreen> {
  List<CryptoCard> cryptoCardList = [];

  DropdownButton<String> androidDropdown() {
    List<DropdownMenuItem<String>> dropDownMenuItems = [];
    for (String currency in currenciesList) {
      dropDownMenuItems.add(DropdownMenuItem(
        value: currency,
        child: Text(currency),
      ));
    }
    return DropdownButton<String>(
      value: selectedCurrency,
      onChanged: (value) {
        setState(() {
          selectedCurrency = value!;
          getCards();
        });
      },
      items: dropDownMenuItems,
    );
  }

  CupertinoPicker iOSPicker() {
    List<Widget> dropDownMenuItems = [];
    for (String currency in currenciesList) {
      dropDownMenuItems.add(Text(currency));
    }
    return CupertinoPicker(
      itemExtent: 30,
      onSelectedItemChanged: (int value) {
        setState(() {
          selectedCurrency = currenciesList[value];
          getCards();
        });
      },
      children: dropDownMenuItems,
    );
  }

  Future<void> getCards() async {
    cryptoCardList = [];
    for (String crypto in cryptoList) {
      String price = await getPrice(crypto);
      setState(() {
        cryptoCardList.add(
          CryptoCard(coinName: crypto, currencyValue: price),
        );
      });
    }
  }

  Future<String> getPrice(String crypto) async {
    String url = '$urlStart/$crypto/$selectedCurrency?$urlEnd';
    String price = '?';

    http.Response response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      var data = jsonDecode((response.body));
      price = data['rate'].toStringAsFixed(2);
    } else {
      print(response.statusCode);
    }

    return price;
  }

  @override
  void initState() {
    getCards();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🤑 Coin Ticker'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Column(
            children: cryptoCardList,
          ),
          Container(
            height: 150.0,
            alignment: Alignment.center,
            padding: const EdgeInsets.only(bottom: 30.0),
            color: Colors.lightBlue,
            child: Platform.isIOS ? iOSPicker() : androidDropdown(),
          ),
        ],
      ),
    );
  }
}

class CryptoCard extends StatelessWidget {
  const CryptoCard({
    super.key,
    required this.coinName,
    required this.currencyValue,
  });

  final String coinName;
  final String currencyValue;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18.0, 18.0, 18.0, 0),
      child: Card(
        color: Colors.lightBlueAccent,
        elevation: 5.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 28.0),
          child: Text(
            '1 $coinName = $currencyValue $selectedCurrency',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20.0,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
