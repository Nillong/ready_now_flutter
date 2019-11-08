import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ready_now_demo/entity/store_entity.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';




class GoogleMaps extends StatefulWidget {

  @override
  _GoogleMapsState createState() => _GoogleMapsState();
}

class _GoogleMapsState extends State<GoogleMaps> {
  LocationData currentLocation;

  // StreamSubscription<LocationData> locationSubscription;

  Location _locationService = new Location();
  List<Marker> markers = <Marker>[];
  List<Widget> boxList = <Widget>[];

  BitmapDescriptor activeMarker = BitmapDescriptor.defaultMarker;
  BitmapDescriptor unActiveMarker = BitmapDescriptor.defaultMarker;
  String error;

  ScrollController _scrollController = new ScrollController();

  @override
  void initState() {
    super.initState();
    _addMarkers();
    initPlatformState();
    _locationService.onLocationChanged().listen((LocationData result) async {
      setState(() {
        currentLocation = result;
      });
    });
  }

  Completer<GoogleMapController> _controller = Completer();

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  void _addMarkers() {
    this._setIcons();
    markers.clear();
    boxList.clear();
    this._getStoreList().then((list){
      setState(() {
        int i = 0;
        list.forEach((data){
          Marker mark = createMarker(data, i++);
          markers.add(mark);
          Widget box = _box(data);
          boxList.add(box);
        });
      });
    });
  }

  void _setIcons(){
    unActiveMarker = BitmapDescriptor.defaultMarkerWithHue(10);
    activeMarker = BitmapDescriptor.defaultMarkerWithHue(120);
  }

  String getCaption(bool hasSeats, DateTime dateTime){
    String snippet = '空席なし';
    if (hasSeats){
      snippet = '空席あり';
    }
    snippet = snippet + " (" + new DateFormat.Hm().format(dateTime) + " 更新)";
    return snippet;
  }

  Marker createMarker(StoreEntry entity, int i) {
    BitmapDescriptor icon = unActiveMarker;
    String snippet = getCaption(entity.hasAvailableSeats, entity.updateDatetime);
    if (entity.hasAvailableSeats){
      icon = activeMarker;
    }
    Marker mark = Marker(
      markerId: MarkerId(entity.key),
      position: LatLng(entity.latitude, entity.longitude),
      icon: icon,
      infoWindow: InfoWindow(
          title: entity.storeName,
          snippet: snippet,
          onTap: () {
            launch(entity.mapUrl);
          },
      ),
      onTap: (){
        _onMarkerTapped(entity.storeName, LatLng(entity.latitude, entity.longitude));
        _scrollController.animateTo(
          i * 268.0,
          curve: Curves.easeOut,
          duration: const Duration(milliseconds: 300),
        );
      },
    );
    return mark;
  }


  Future<List<StoreEntry>> _getStoreList() async{
    List<StoreEntry> list = <StoreEntry>[];
    QuerySnapshot querySnapshot = await Firestore.instance.collection("store").getDocuments();
    querySnapshot.documents.forEach((f){
      list.add(StoreEntry.fromSnapShot(f));
    });
    return list;
  }

  void _onMarkerTapped(String name, LatLng latLng){
    print(name);
  }

  @override
  Widget build(BuildContext context) {
    if (currentLocation == null) {
      return Center(
        child: CircularProgressIndicator(),
      );
    } else {
      return MaterialApp(
        home: Stack(
          children: <Widget>[
            GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: LatLng(currentLocation.latitude, currentLocation.longitude),
                zoom: 17.0,
              ),
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              markers: Set<Marker>.of(markers),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 20.0),
                height: 150.0,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  controller: _scrollController,
                  children: boxList.map((Widget box) {
                    return box;
                  }).toList(),
                ),
              ),
            ),
          ],)
      );
    }
  }

  Widget _box(StoreEntry data){
    return Stack(
      children: <Widget>[
        SizedBox(width: 10.0),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: (){
              _gotoLocation(data.latitude, data.longitude);
            },
            child: Container(
              child: FittedBox(
                child: Material(
                  color: Colors.white,
                  elevation: 14.0,
                  borderRadius: BorderRadius.circular(12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                        width: 180,
                        height: 200,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12.0),
                          child: Image(
                            fit: BoxFit.fill,
                            image: NetworkImage(data.imageUrl),
                          ),
                        ),
                      ),
                      Container(
                        child: Padding(
                          padding: EdgeInsets.all(12.0),
                          child: Column(
                            children: <Widget>[
                              Text(data.storeName,
                                textAlign: TextAlign.left,
                                style: new TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                              ),
                              Row(
                                children: <Widget>[
                                  Icon(Icons.location_on,
                                    color: data.hasAvailableSeats ? Colors.green : Colors.red,
                                    size: 16.0,),
                                  SizedBox(width: 10.0,),
                                  Text(getCaption(data.hasAvailableSeats, data.updateDatetime),
                                  style: TextStyle(color: Colors.black38),)
                                ],
                              ),
                              SizedBox(height: 20.0,),
                              FlatButton(
                                textTheme: ButtonTextTheme.primary,
                                child: Row(
                                  children: <Widget>[
                                    Icon(
                                      Icons.map
                                    ),
                                    Text('Open Map')
                                  ],
                                ),
                                onPressed: () => launch(data.mapUrl),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )

        ),
      ],
    );
  }


  Future<void> _gotoLocation(double lat,double long) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: LatLng(lat, long), zoom: 18)));
  }

  void initPlatformState() async {
    LocationData myLocation;
    try {
      myLocation = await _locationService.getLocation();
      error = "";
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENITED')
        error = 'Permission denited';
      else if (e.code == 'PERMISSION_DENITED_NEVER_ASK')
        error =
        'Permission denited - please ask the user to enable it from the app settings';
      myLocation = null;
    }
    setState(() {
      currentLocation = myLocation;
    });
  }
}