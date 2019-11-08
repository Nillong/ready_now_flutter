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
        list.forEach((data){
          Marker mark = createMarker(data);
          markers.add(mark);
          Widget box = _box(data.imageUrl, data.latitude, data.longitude, data.storeName);
          boxList.add(box);
        });
      });
    });
  }

  void _setIcons(){
    unActiveMarker = BitmapDescriptor.defaultMarkerWithHue(10);
    activeMarker = BitmapDescriptor.defaultMarkerWithHue(120);
  }

  Marker createMarker(StoreEntry entity) {
    BitmapDescriptor icon = unActiveMarker;
    String snippet = '空席なし';
    if (entity.hasAvailableSeats){
      icon = activeMarker;
      snippet = '空席あり';
    }
    snippet = snippet + " (" + new DateFormat.Hm().format(entity.updateDatetime) + " 更新)";
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

  Widget _box(String _imageUrl, double lat, double long, String name){
    return Stack(
      children: <Widget>[
        SizedBox(width: 10.0),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child:         GestureDetector(
            onTap: (){
              _gotoLocation(lat, long);
            },
            child: Container(
              child: FittedBox(
                child: Material(
                  color: Colors.white,
                  elevation: 14.0,
                  borderRadius: BorderRadius.circular(12.0),
                  shadowColor: Color(0x802196f3),
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
                            image: NetworkImage(_imageUrl),
                          ),
                        ),
                      ),
                      Container(
                        child: Padding(
                          padding: EdgeInsets.all(12.0),
                          child: Text(name),
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