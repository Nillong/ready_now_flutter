import 'package:cloud_firestore/cloud_firestore.dart';

class StoreEntry {
  String key;
  String storeName;
  double latitude;
  double longitude;
  bool hasAvailableSeats;
  DateTime updateDatetime;

  StoreEntry(this.key, this.storeName, this.latitude, this.longitude, this.hasAvailableSeats, this.updateDatetime);

  StoreEntry.fromSnapShot(DocumentSnapshot snapshot):
        key = snapshot.documentID,
        storeName = snapshot.data["storeName"],
        latitude = snapshot.data["latitude"],
        longitude = snapshot.data["longitude"],
        hasAvailableSeats = snapshot.data["hasAvailableSeats"],
        updateDatetime = snapshot.data["updateDatetime"].toDate();

  toJson() {
    return {
      "key": key,
      "storeName": storeName,
      "latitude": latitude,
      "longitude": longitude,
      "hasAvailableSeats": hasAvailableSeats,
      "updateDatetime": updateDatetime.millisecondsSinceEpoch,
    };
  }
}