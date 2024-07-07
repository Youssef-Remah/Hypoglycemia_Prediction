import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:hypoglycemia_prediction/shared/components/constants.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> requestCallPermission() async {
  var status = await Permission.phone.status;
  if (!status.isGranted) {
    var result = await Permission.phone.request();
    if (result.isGranted) {
      print("Call permission granted");
      // Proceed to make the call
    } else {
      print("Call permission denied");
    }
  }
}

Future<void> directCall() async {
  requestCallPermission();
  String number = globalEmergencyContactNumber; //set the number here
  bool? res = await FlutterPhoneDirectCaller.callNumber(number);
}