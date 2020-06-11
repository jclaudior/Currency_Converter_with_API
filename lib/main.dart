import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

const request = "https://api.hgbrasil.com/finance?format=json&key=9c4b3e48";

void main () async{
  runApp(MaterialApp(
    home: Home(),
    theme: ThemeData(
        hintColor: Colors.amber,
        primaryColor: Colors.white,
        inputDecorationTheme: InputDecorationTheme(
          enabledBorder:
          OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
          focusedBorder:
          OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
          hintStyle: TextStyle(color: Colors.amber),
        )),
  ));
}

Future<Map> getData() async {
  http.Response response = await http.get(request);
  return json.decode(response.body);
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  double _dolar;
  double _euro;

  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();

  void _realChanged(String text){
    if(text.isEmpty) {
      _clearAll();
      return;
    }
   double real = double.parse(text);
   dolarController.text = (real/this._dolar).toStringAsFixed(2);
   euroController.text = (real/_euro).toStringAsFixed(2);
  }

  void _dolarChanged(String text){
    if(text.isEmpty) {
      _clearAll();
      return;
    }
    double dolar = double.parse(text);
    realController.text = (dolar * this._dolar).toStringAsFixed(2);
    euroController.text = (dolar * this._dolar/this._euro).toStringAsFixed(2);
  }

  void _euroChanged(String text){
    if(text.isEmpty) {
      _clearAll();
      return;
    }
    double euro = double.parse(text);
    realController.text = (euro * this._euro).toStringAsFixed(2);
    dolarController.text = (euro * this._euro/_dolar).toStringAsFixed(2);
  }

  void _clearAll(){
    realController.text = "";
    dolarController.text = "";
    euroController.text = "";
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Text("\$ Conversor \$"),
          backgroundColor: Colors.amber,
          centerTitle: true,
        ),
      body: FutureBuilder<Map>(
        future: getData(),
        builder: (context, snapshot){
          switch(snapshot.connectionState){
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                child: Text(
                  "Carregando dados..",
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 25.0
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            default:
              if(snapshot.hasError){
                return Center(
                  child: Text(
                    "Erro ao Carregar dados!",
                    style: TextStyle(
                        color: Colors.amber,
                        fontSize: 25.0
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              }
              else{
                _dolar = snapshot.data["results"]["currencies"]["USD"]["buy"];
                _euro = snapshot.data["results"]["currencies"]["EUR"]["buy"];
                return SingleChildScrollView(
                  padding: EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Icon(
                        Icons.monetization_on,
                        size: 150.0,
                        color: Colors.amber,

                      ),
                      Divider(),
                      buildTextField("Reais","R\$", realController,  _realChanged),
                      Divider(),
                      buildTextField("Dolares","US\$", dolarController,  _dolarChanged),
                      Divider(),
                      buildTextField("Euros","€", euroController,  _euroChanged)
                    ],
                  ),
                );
              }
          }
        },
      ),
      );
  }
}

buildTextField(String label, String prefixe, TextEditingController controller, Function function) {
  return TextField(
    decoration: InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.amber),
      border: OutlineInputBorder(),
      prefixText: prefixe,
    ),
    style: TextStyle(color: Colors.amber, fontSize: 25.0),
    controller: controller,
    onChanged: function,
    keyboardType: TextInputType.numberWithOptions(decimal: true),
  );
}
