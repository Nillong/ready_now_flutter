import 'package:device_info/device_info.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'dart:io';

class UserInfoManager{

  static final USER_STATUS = 'userStatus';
  static final USER_OPE_HISTORT = 'userOperationHistory';
  static final USER_ACC_HISTORT = 'userAccessMapHistory';

  String deviceId = null;
  int searchCount = null;
  FeedBackStatus feedBackStatus = null;

  Future<Stream<DocumentSnapshot>> userStatus;

  static final UserInfoManager instance = new UserInfoManager();

  UserInfoManager(){
    switch (Platform.operatingSystem){
      case 'android' :
        _getAndroidDeviceId().then((info){
          this.deviceId = info.model + ':' + info.androidId;
          _setUserStatus();
        });
        break;
      case 'ios' :
        _getIosInfo().then((info){
          this.deviceId = info.model + ':' + info.identifierForVendor;
          _setUserStatus();
        });
        break;
    }
  }

  Future<AndroidDeviceInfo> _getAndroidDeviceId() async{
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    return await deviceInfo.androidInfo;
  }

  Future<IosDeviceInfo> _getIosInfo() async{
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    return await deviceInfo.iosInfo;
  }

  void _setUserStatus() async{
    this.userStatus = _getUserStatus();
    userStatus.then((snapshots){
      snapshots.listen((doc){
        if(doc.data != null && doc.data.length > 0){
          Map<String, dynamic> data = doc.data;
          this.searchCount = data['searchCount'];
          this.feedBackStatus = FeedBackStatusHelper.getStatus(data['feedBackStatus']);
        }else{
          this.searchCount = 0;
          this.feedBackStatus = FeedBackStatusHelper.getStatus(0);
        }
      });
    });
  }

  Future<Stream<DocumentSnapshot>> _getUserStatus() async {
    return await Firestore.instance.collection(USER_STATUS).document(this.deviceId).snapshots();
  }

  bool shouldAnswerFeedBack(){
    if (this.feedBackStatus == FeedBackStatus.none && this.searchCount >= 3){
      return true;
    }
    return false;
  }

  void clickFeedBacked(){
    feedBackStatus = FeedBackStatus.feedBacked;
    _uploadStatus(deviceId, this.searchCount, FeedBackStatusHelper.getValue(feedBackStatus));
  }

 void updateSearchCount(){
    if (this.deviceId != null){
      if (searchCount > 0){
        int count = searchCount + 1;
        this._uploadStatus(deviceId, count, FeedBackStatusHelper.getValue(this.feedBackStatus));
      }else{
        this._createStatus(deviceId, 1, FeedBackStatusHelper.getValue(this.feedBackStatus));
      }
    }
  }

  void _uploadStatus(String deviceId, int searchCount, int feedBackStatusValue) async {
    await Firestore.instance
        .collection(USER_STATUS)
        .document(deviceId)
        .updateData({"searchCount": searchCount, "feedBackStatus" : feedBackStatusValue});
  }

  void _createStatus(String deviceId, int searchCount, int feedBackStatusValue) async {
    await Firestore.instance
        .collection(USER_STATUS)
        .document(deviceId)
        .setData({"searchCount": searchCount, "feedBackStatus" : feedBackStatusValue});
  }

  void createOperationLog(UserOperation operation) async {
    DateTime now = DateTime.now();
    String date = new DateFormat("yyyy.MM.dd (EEE) HH:mm:ss").format(now);
    await Firestore.instance
        .collection(USER_OPE_HISTORT)
        .document((now.millisecondsSinceEpoch).toString() + "-" + deviceId)
        .setData({"operation": operation.toString(), "dateTimesStr": date, "dateTime": now.millisecondsSinceEpoch, "deviceId" : deviceId});
  }

  void createAccessMap(String key, String name, GeoPoint storePoint, GeoPoint userPoint) async {
    DateTime now = DateTime.now();
    String date = new DateFormat("yyyy.MM.dd (EEE) HH:mm:ss").format(now);
    await Firestore.instance
        .collection(USER_ACC_HISTORT)
        .document((now.millisecondsSinceEpoch).toString() + "-" + deviceId)
        .setData({"storeKey": key, "storeName": name, "storeGeoPoint": storePoint, "userGeoPoint": userPoint, "dateTimesStr": date, "dateTime": now.millisecondsSinceEpoch, "deviceId" : deviceId});
  }
}

enum UserOperation {
  openApp,
  openMap,
  openFeedBackUrl,
  openExternalMapApp,
  clickMapPoint,
  clickFeedBackLater,
}

enum FeedBackStatus {
  none,
  feedBacked,
  neverDisplay
}

class FeedBackStatusHelper{
  static int getValue(FeedBackStatus status){
    switch(status){
      case FeedBackStatus.none:
        return 0;
      case FeedBackStatus.feedBacked:
        return 1;
      case FeedBackStatus.neverDisplay:
        return 9;
      default:
        return 0;
    }
  }

  static FeedBackStatus getStatus(int value){
    switch(value){
      case 0:
        return FeedBackStatus.none;
      case 1:
        return FeedBackStatus.feedBacked;
      case 9:
        return FeedBackStatus.neverDisplay;
      default:
        return FeedBackStatus.none;
    }
  }

}