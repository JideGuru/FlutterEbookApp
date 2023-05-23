import 'package:fluttertoast/fluttertoast.dart';

class FlutterToastWrapper {
  Future<bool?> showToast(
      {required String msg,
      Toast? toastLength,
      int? timeInSecForIosWeb}) async {
    return Fluttertoast.showToast(
      msg: msg,
      toastLength: toastLength,
      timeInSecForIosWeb: timeInSecForIosWeb ?? 1,
    );
  }
}
