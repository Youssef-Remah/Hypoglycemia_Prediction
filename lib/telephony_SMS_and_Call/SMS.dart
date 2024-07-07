import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hypoglycemia_prediction/shared/components/constants.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:telephony/telephony.dart';
import 'package:http/http.dart' as http;
import '../shared/components/resuable_components.dart';

Future<String> shortenUrl(String url) async {
  final response =
  await http.get(Uri.parse('https://tinyurl.com/api-create.php?url=$url'));
  if (response.statusCode == 200) {
    return response.body;
  } else {
    throw Exception('Failed to shorten URL');
  }
}

Future<void> sendSmsWithLocation() async {
  if(globalEmergencyContactNumber=="") return;

  String globalMessage = "Need Help Location!";
  final Telephony telephony = Telephony.instance;
  await checkPermissions();

  bool smsPermissionGranted = await Permission.sms.isGranted;
  LocationPermission locationPermission = await Geolocator.checkPermission();

  if (smsPermissionGranted &&
      (locationPermission == LocationPermission.whileInUse ||
          locationPermission == LocationPermission.always)) {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      String locationUrl =
          "https://www.google.com/maps/search/?api=1&query=${position.latitude},${position.longitude}";

      // Shorten the URL
      try {
        String shortenedUrl = await shortenUrl(locationUrl);
        globalMessage = "Need Help! Location: $shortenedUrl";
      } catch (e) {
        globalMessage =
        "Need Help! Location:${position.latitude},${position.longitude}";
        print('Error shortening URL: $e');
        // showSnackBar(context, 'Error shortening URL');
      }

      telephony.sendSms(
        to: globalEmergencyContactNumber,
        message: globalMessage,
        statusListener: (SendStatus status) {
          if (status == SendStatus.SENT) {
            // showSnackBar(context, 'SMS sent successfully');
          } else if (status == SendStatus.DELIVERED) {
            // showSnackBar(context, 'SMS Delivered to $contact');
          } else {
            // showSnackBar(context, 'Failed to send SMS to $contact');
          }
        },
      );
    } catch (e) {
      print('Error getting location: $e');
    }
  } else if (smsPermissionGranted) {
    globalMessage = "Emergency! I need help. My location is unavailable.";

    telephony.sendSms(
      to: globalEmergencyContactNumber,
      message: globalMessage,
      statusListener: (SendStatus status) {
        if (status == SendStatus.SENT) {
          // showSnackBar(context, 'SMS sent successfully to $contact');
        } else {
          // showSnackBar(context, 'Failed to send SMS to $contact');
        }
      },
    );
  } else {
    print('Permissions not granted');
  }
}
