import 'package:cloud_firestore/cloud_firestore.dart';

class StoreEntry {
  String key;
  String storeName;
  double latitude;
  double longitude;
  String mapUrl;
  String imageUrl;
  bool hasAvailableSeats;
  DateTime updateDatetime;


  StoreEntry(this.key, this.storeName, this.latitude, this.longitude, this.mapUrl, this.imageUrl, this.hasAvailableSeats, this.updateDatetime);

  StoreEntry.fromSnapShot(DocumentSnapshot snapshot):
        key = snapshot.documentID,
        storeName = snapshot.data["storeName"],
        latitude = snapshot.data["latitude"],
        longitude = snapshot.data["longitude"],
        mapUrl = snapshot.data["mapUrl"],
        imageUrl = snapshot.data["imageUrl"] != null ? snapshot.data["imageUrl"]  : noImage,
        hasAvailableSeats = snapshot.data["hasAvailableSeats"],
        updateDatetime = snapshot.data["updateDatetime"].toDate();

  static String noImage = 'https://www.shoshinsha-design.com/wp-content/uploads/2016/10/%E3%82%B9%E3%82%AF%E3%83%AA%E3%83%BC%E3%83%B3%E3%82%B7%E3%83%A7%E3%83%83%E3%83%88-2016-10-08-23.40.04-580x439.png';

  toJson() {
    return {
      "key": key,
      "storeName": storeName,
      "latitude": latitude,
      "longitude": longitude,
      "imageUrl": imageUrl,
      "hasAvailableSeats": hasAvailableSeats,
      "updateDatetime": updateDatetime.millisecondsSinceEpoch,
    };
  }
}