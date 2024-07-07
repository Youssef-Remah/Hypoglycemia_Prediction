import 'package:geolocator/geolocator.dart';
import 'package:hypoglycemia_prediction/shared/cubit/cubit.dart';
import 'package:hypoglycemia_prediction/shared/network/local/cache_helper.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

String? uId;

String globalEmergencyContactNumber = CacheHelper.getData(key: 'globalEmergencyContactNumber') ?? '';

// Create a global instance of ModelDeploymentCubit
final modelDeploymentCubit = ModelDeploymentCubit();

String getCurrentTime()
{
  DateTime now = DateTime.now();

  DateFormat formatter = DateFormat('yyyy-MM-dd hh:mm:ss a');

  String formattedTime = formatter.format(now);

  return formattedTime;
}

Future<void> checkPermissions() async
{
  print('Requesting permissions...');
  // Request multiple permissions using a map
  Map<Permission, PermissionStatus> statuses = await [
    Permission.sms,
    Permission.location,
    Permission.phone,
    Permission.notification,
    Permission.bluetooth,
    Permission.bluetoothConnect,
    Permission.bluetoothScan,
    Permission.accessMediaLocation,
  ].request();

  // Print the status of each permission
  statuses.forEach((permission, status)
  {
    print('${permission.toString()}: ${status.toString()}');
  });

  // Check if location services are enabled
  if (!await Geolocator.isLocationServiceEnabled()) {
    print('Location services are disabled. Opening settings...');
    await Geolocator.openLocationSettings();
  }
}

Future<void> waitTime(int seconds) async {
  await Future.delayed(Duration(seconds: seconds));
}
