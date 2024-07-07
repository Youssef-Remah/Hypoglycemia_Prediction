import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:hypoglycemia_prediction/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hypoglycemia_prediction/modules/dietary_manager/cubit/cubit.dart';
import 'package:hypoglycemia_prediction/modules/emergency_contact/cubit/cubit.dart';
import 'package:hypoglycemia_prediction/modules/home_page/home_screen.dart';
import 'package:hypoglycemia_prediction/modules/insights/cubit/cubit.dart';
import 'package:hypoglycemia_prediction/modules/settings/cubit/cubit.dart';
import 'package:hypoglycemia_prediction/modules/smartwatch_connection/device_screen/cubit/cubit.dart';
import 'package:hypoglycemia_prediction/modules/smartwatch_connection/device_screen/cubit/states.dart';
import 'package:hypoglycemia_prediction/modules/smartwatch_connection/scan_screen/cubit/cubit.dart';
import 'package:hypoglycemia_prediction/modules/welcome_page/welcome_screen.dart';
import 'package:hypoglycemia_prediction/shared/bloc_observer.dart';
import 'package:hypoglycemia_prediction/shared/components/constants.dart';
import 'package:hypoglycemia_prediction/shared/components/resuable_components.dart';
import 'package:hypoglycemia_prediction/shared/cubit/cubit.dart';
import 'package:hypoglycemia_prediction/shared/network/local/cache_helper.dart';
import 'package:hypoglycemia_prediction/shared/network/remote/dio_helper.dart';
import 'package:permission_handler/permission_handler.dart';
import 'localNotification/local_notification.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

void main() async
{
  WidgetsFlutterBinding.ensureInitialized();

  await checkPermissions();

  tz.initializeTimeZones(); // to use the timezone for schedule notification

  await localNotification().init(); // initialize local notification

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await CacheHelper.init();

  uId = CacheHelper.getData(key: 'userToken');

  DioHelper.mealInitApi();

  Bloc.observer = MyBlocObserver();

  // modelDeploymentCubit.loadModel().then((value)
  // {
  //   modelDeploymentCubit.runInference();
  // });

  runApp(MyApp(modelDeploymentCubit: modelDeploymentCubit));
}

class MyApp extends StatelessWidget
{
  final ModelDeploymentCubit modelDeploymentCubit;

  const MyApp({Key? key, required this.modelDeploymentCubit}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers:
      [
        BlocProvider(create: (BuildContext context) => EmergencyContactCubit()..getEmergencyContacts()),
        BlocProvider(create: (BuildContext context) => DietaryManagerCubit()..getMealsFromDatabase()),
        BlocProvider(create: (BuildContext context) => ProfileSettingsCubit()),
        BlocProvider(create: (BuildContext context) => InsightsCubit()),
        BlocProvider(create: (BuildContext context) => BleDeviceCubit()),
        BlocProvider(create: (BuildContext context) => ScanCubit()),
        // Provide the global instance to the widget tree
        BlocProvider.value(value: modelDeploymentCubit),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            useMaterial3: false,
            scaffoldBackgroundColor: Colors.white,
            appBarTheme: const AppBarTheme(
              systemOverlayStyle: SystemUiOverlayStyle(
                statusBarColor: Colors.blue,
              ),
              color: Colors.blue,
              centerTitle: true,
            )),
        home: BlocListener<BleDeviceCubit, BleDeviceStates>(
          listener: (context, state)
          {
            if (state is BleDeviceConnectedSuccessState)
            {
              showFlutterToast(
                context: context,
                text: 'Connected Successfully',
                state: ToastStates.SUCCESS,
              );

              BleDeviceCubit.get(context)
                  .reconnectionTimer(BleDeviceCubit.get(context).device!);
            }

            if (state is BleDiscoverServicesSuccessState) {
              BleDeviceCubit.get(context).readHeartRateMeasurements();

              BleDeviceCubit.get(context).readActivityGoal();
            }

            if (state is BleDeviceDisconnectedSuccessState) {
              BleDeviceCubit.get(context).reconnectionTimer(
                  BleDeviceCubit.get(context).device!,
                  cancelTimer: true);

              showFlutterToast(
                context: context,
                text: 'Device Disconnected',
                state: ToastStates.WARNING,
                textColor: Colors.black,
              );
            }
          },
          child: (uId != null) ? const HomeScreen() : WelcomeScreen(),
        ),
      ),
    );
  }
}
