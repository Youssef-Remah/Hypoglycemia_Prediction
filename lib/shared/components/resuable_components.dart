import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

void showFlutterToast({
  required context,
  required String text,
  required ToastStates state,
  Color textColor = Colors.white,
}) {
  showToast(
    text,
    borderRadius: BorderRadius.circular(10.0),
    context: context,
    animation: StyledToastAnimation.slideFromBottom,
    reverseAnimation: StyledToastAnimation.slideFromTopFade,
    position: StyledToastPosition.top,
    duration: const Duration(seconds: 5),
    animDuration: const Duration(milliseconds: 250),
    backgroundColor: chooseToastState(state: state),
    textStyle: TextStyle(fontSize: 16.0, color: textColor),
  );
}

enum ToastStates { SUCCESS, ERROR, WARNING }

Color chooseToastState({
  required ToastStates state,
}) {
  Color color;

  switch (state) {
    case ToastStates.SUCCESS:
      color = Colors.green;
      break;

    case ToastStates.ERROR:
      color = Colors.red;
      break;

    case ToastStates.WARNING:
      color = Colors.amber;
      break;
  }

  return color;
}

Widget buildListItem({
  required IconData prefixIcon,
  required String title,
  required context,
  required Widget destinationWidget,
}) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.grey[300],
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(
      children: [
        const SizedBox(
          width: 10.0,
        ),
        Icon(prefixIcon),
        const SizedBox(
          width: 20.0,
        ),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18.0,
            ),
          ),
        ),
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => destinationWidget,
              ),
            );
          },
          icon: const Icon(Icons.arrow_forward_ios_rounded),
        ),
      ],
    ),
  );
}

// SnackBar Widget:
void showSnackBar(BuildContext context, String text) {
  final snackBar = SnackBar(
    content: Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
      textAlign: TextAlign.center,
    ),
    backgroundColor: Colors.blueAccent,
  );

  ScaffoldMessenger.of(context)
    ..removeCurrentSnackBar()
    ..showSnackBar(snackBar);
}

void alertDialog(BuildContext context) {
  var alertStyle = AlertStyle(
    animationType: AnimationType.fromBottom,
    isCloseButton: true,
    titleTextAlign: TextAlign.center,
    isOverlayTapDismiss: false,
    descStyle: TextStyle(fontWeight: FontWeight.bold),
    descTextAlign: TextAlign.start,
    alertElevation: 30.0,
    animationDuration: Duration(milliseconds: 600),
    alertBorder: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(30.0),
      side: BorderSide(
        color: Colors.blueAccent.withOpacity(0.5),
      ),
    ),
    titleStyle: TextStyle(
      color: Colors.red,
    ),
    alertAlignment: Alignment.center,
  );
  Alert(
    context: context,
    title: "Hello there! ⚠️",
    style: alertStyle,
    content: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 150,
            child: Image.asset(
              "lib/assets/images/wired-lineal-268-avatar-man.gif",
              fit: BoxFit.fitHeight,
            ),
          ),
          Text(
            "We are trying to keep you safe🛡️\n",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15.5, color: Colors.blueAccent,fontWeight: FontWeight.w800),
          ),
          Padding(
            padding: const EdgeInsets.all(2.0),
            child: Text(
              "• A little favour, please make sure that you give permissions for all of those ⏬ ",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800),
            ),
          ),
          Text(
            " WIFI,SMS,Location,Bluetooth,Nearby Devices And Call\n",
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 13.55, color: Colors.red, fontWeight: FontWeight.w700),
          ),
          Text(
            "• For the app to work best, please keep it running in the background.\n",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800,color: Colors.grey),
          ),
          Text(
            "• To get the most out of the app, make sure your device sound and vibration aren't muted.\n",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800),
          )
        ],
      ),
    ),
    buttons: [
      DialogButton(
        child: Text(
          "Sure, Let's Do It!",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        onPressed: () => Navigator.pop(context),
        color: Color.fromRGBO(0, 179, 134, 1.0),
        radius: BorderRadius.circular(15.0),
        width: 200,
      ),
    ],
  ).show();
}
