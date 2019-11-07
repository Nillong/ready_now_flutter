import 'package:device_info/device_info.dart';

class UserLogService {
  void execute(){
    Future<String> id = getUserId();
    id.then((value){
      print(value);
    });
  }

  Future<String> getUserId() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    print('Running on ${androidInfo.androidId}');  // => Android デバイスID出力
    return androidInfo.androidId;
  }

}