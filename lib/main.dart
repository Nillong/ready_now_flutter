import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:ready_now_demo/service/user_log_service.dart';
import 'map/google_maps.dart';
import 'package:device_info/device_info.dart';

void main() => runApp(MyApp());

class ReadyNowState extends State<ReadyNow> {

  bool _isUseHere = true;
  List<String> _numOfPeopleList =  <String>['1人', '2人', '3人', '4人'];
  String _numOfPeopleValue = '1人';

  bool _optPlug = false;
  bool _optWifi = false;
  var selectGpsArea = [true, false, false];

  Color themeColor = Colors.blueGrey;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('カフェ検索'),
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        padding: EdgeInsets.all(0.0),
        child:  Column(
          children: <Widget>[
            new Expanded(
              child: new SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    SizedBox(height: 10.0,),
                    Container(
                      padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 4.0),
                      child: TypeAheadField(
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
                    ),
                    CheckboxListTile(
                      activeColor: themeColor,
                      title: Text('現在地を使う'),
                      onChanged: _useHere,
                      value: _isUseHere,
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(0, 8.0, 0, 0),
                      child: ToggleButtons(
                        children: [
                          Container(
                            child: Text('100m以内'),
                            width: 115,
                            alignment: Alignment.center,
                          ),
                          Container(
                            child: Text('200m以内'),
                            width: 115,
                            alignment: Alignment.center,
                          ),
                          Container(
                            child: Text('200m以内'),
                            width: 115,
                            alignment: Alignment.center,
                          ),
                        ],
                        onPressed: (int index){
                          setState(() {
                            for (int buttonIndex = 0; buttonIndex < selectGpsArea.length; buttonIndex++) {
                              if (buttonIndex == index) {
                                selectGpsArea[buttonIndex] = true;
                              } else {
                                selectGpsArea[buttonIndex] = false;
                              }
                            }
                          });
                        },
                        isSelected: selectGpsArea,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(32.0),
                      alignment: Alignment.topLeft,
                      child: DropdownButton<String>(
                        value: _numOfPeopleValue,
                        items: _numOfPeopleList.map((String value) {
                          return new DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (e) {setState(() {
                          _numOfPeopleValue = e;
                        });
                        },
                      ),
                    ),
                    Container(
                      child: Column(
                        children: <Widget>[
                          Container(
                            child: Text('オプション',
                              textAlign: TextAlign.left,
                              style: new TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                            ),
                            alignment: Alignment.topLeft,
                            margin: EdgeInsets.all(20.0),
                          ),
                          CheckboxListTile(
                            activeColor: themeColor,
                            title: Text('電源コンセント'),
                            onChanged: (e){setState(() {
                              _optPlug = e;
                            });},
                            value: _optPlug,
                            controlAffinity: ListTileControlAffinity.leading,
                          ),
                          CheckboxListTile(
                            activeColor: themeColor,
                            title: Text('フリーwifi'),
                            onChanged: (e){setState(() {
                              _optWifi = e;
                            });},
                            value: _optWifi,
                            controlAffinity: ListTileControlAffinity.leading,
                          ),
                        ],
                      ),
                    ),

                  ],
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(16.0),
              child: ButtonTheme(
                minWidth: double.infinity,
                child: RaisedButton(
                  color: themeColor,
                  textColor: Colors.white,
                  onPressed: _searchMap,
                  child: const Text(
                      '検索',
                      style: TextStyle(fontSize: 20)
                  ),
                ),
              )
              ,
            ),
          ],
        ),
      ),
    );
  }

  void _searchMap(){
    new UserLogService().execute();
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
