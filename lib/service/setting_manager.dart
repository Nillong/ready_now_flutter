import 'package:cloud_firestore/cloud_firestore.dart';

class CommonSettingManager {

  Map<CommonSettingDocId, Map<String, dynamic>> result = new Map<CommonSettingDocId, Map<String, dynamic>>();
  static final CommonSettingManager instance = new CommonSettingManager();

  CommonSettingManager() {
    _setSettings();
  }

  void _setSettings() async {
    QuerySnapshot querySnapshot = await Firestore.instance.collection("commonSettings").getDocuments();
    querySnapshot.documents.forEach((f){
      CommonSettingDocId id = CommonSettingHelper.getDocId(f.documentID);
      if (id != null){
        this.result[id] = f.data;
      }
    });
  }

  dynamic getValue(CommonSettingDocId id, String key){
    Map<String, dynamic> map = this.result[id];
    if (map != null && map.containsKey(key)){
      return map[key];
    }
    return null;
  }
}

enum CommonSettingDocId {
  feedback,
}

class CommonSettingHelper{

  static CommonSettingDocId getDocId(String value){
    switch(value){
      case 'feedback':
        return CommonSettingDocId.feedback;
      default:
        return null;
    }
  }

}