import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:ready_now_demo/service/setting_manager.dart';
import 'package:ready_now_demo/service/user_info_manager.dart';
import 'map/google_maps.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(MyApp());

class ReadyNowState extends State<ReadyNow> {

  static List<String> _numOfPeopleList =  <String>['1人', '2人', '3人', '4人'];
  static List<bool> selectGpsArea = [true, false, false];

  String _numOfPeopleValue = '1人';

  bool _isUseHere = true;
  bool _optPlug = false;
  bool _optWifi = false;

  Color themeColor = Colors.blueGrey;

  UserInfoManager userInfo = UserInfoManager.instance;
  CommonSettingManager settingManager = CommonSettingManager.instance;
  Timer feedbackTimer;

  @override
  void initState(){
    //アプリ起動時に一度だけ実行される
    _showFeedBackDialog();
  }


  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
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
                          enabled: !_isUseHere,
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
                    SizedBox(height: 8.0,),
                    ToggleButtons(
                      children: [
                        Container(
                          child: Text('100m以内'),
                          width: (size.width - 40) / 3,
                          alignment: Alignment.center,
                        ),
                        Container(
                          child: Text('200m以内'),
                          width: (size.width - 40) / 3,
                          alignment: Alignment.center,
                        ),
                        Container(
                          child: Text('300m以内'),
                          width: (size.width - 40) / 3,
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

  _showFeedBackDialog(){
    feedbackTimer = new Timer(new Duration(seconds: 1), (){
      if (userInfo.shouldAnswerFeedBack()){
        _showDialog();
      }
    });
  }

  void _showDialog() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("いつもご利用いただきありがとうございます"),
          content: new Text("品質向上のためアンケートにご協力ください。"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("あとで回答する"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            new FlatButton(
              child: new Text("今すぐ回答する"),
              onPressed: () {
                _openFeedBackForm();
              },
            ),
          ],
        );
      },
    );
  }

  void _openFeedBackForm(){
    String url = settingManager.getValue(CommonSettingDocId.feedback, 'url');
    launch(url).then((e){
      if (e){
        userInfo.clickFeedBacked();
        Navigator.of(context).pop();
      }
    });
  }

  void _searchMap(){
    feedbackTimer.cancel();
    userInfo.updateSearchCount();
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
