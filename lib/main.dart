import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'map/google_maps.dart';

void main() => runApp(MyApp());

class ReadyNowState extends State<ReadyNow> {

  bool _isUseHere = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Name Generator'),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.list), onPressed: _pushSaved),

        ],
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        padding: EdgeInsets.all(16.0),
        child:  Column(
          children: <Widget>[
            SizedBox(height: 10.0,),
            TypeAheadField(
              textFieldConfiguration: TextFieldConfiguration(
                  autofocus: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: '違う住所を使う（例：東京駅）',
                  )
              ),
              suggestionsCallback: (pattern) async {
                return null;
              },
              itemBuilder: (context, suggestion) {
                return ListTile(
                  title: Text(context.toString()),
                );
              },
              onSuggestionSelected: (suggestion) {

              },
            ),
            CheckboxListTile(
              title: Text('現在地を使う'),
              onChanged: _useHere,
              value: _isUseHere,
            ),
            RaisedButton(
              onPressed: _searchMap,
              child: const Text(
                  '検索',
                  style: TextStyle(fontSize: 20)
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _pushSaved(){
  }

  void _searchMap(){
    Navigator.of(context).push(
      MaterialPageRoute<void>(
          builder: (BuildContext context) {
            return Scaffold(
                appBar: AppBar(
                  title: Text('カフェ検索'),
                ),
                body: Container(
                  child: GoogleMaps(),
                )
            );
          }
      ),
    );
  }


  void _useHere(bool e){
    setState(() {
      _isUseHere = e;
    });
  }

  void setUseHere(bool e) {
  }
}

class ReadyNow extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ReadyNowState();
  }
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '',
      theme: ThemeData(
          primaryColor: Colors.blueGrey
      ),
      home: ReadyNow(),
    );
  }
}
