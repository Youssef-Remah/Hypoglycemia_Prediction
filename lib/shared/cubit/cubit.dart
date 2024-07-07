import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:hypoglycemia_prediction/localNotification/local_notification.dart';
import 'package:hypoglycemia_prediction/models/user_model.dart';
import 'package:hypoglycemia_prediction/shared/components/constants.dart';
import 'package:hypoglycemia_prediction/shared/cubit/states.dart';
import 'package:hypoglycemia_prediction/telephony_SMS_and_Call/SMS.dart';
import 'package:hypoglycemia_prediction/telephony_SMS_and_Call/call.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class ModelDeploymentCubit extends Cubit<ModelDeploymentStates>
{
  ModelDeploymentCubit() : super(ModelDeploymentInitialState());

  static ModelDeploymentCubit get(context) => BlocProvider.of(context);

  UserModel? userModel;

  List<double> hearRateReadings = [];

  List<double> shortTermInsulinDoses = [];

  List<double> basalInsulinDoses = [];

  List<double> carbohydrates = [];

  List<double> glucoseReadings = [];

  List<int> year = [];

  List<int> day = [];

  List<int> month = [];

  List<int> hour = [];

  List<int> minute = [];

  final double mean_glucose = 156.26076125389574;

  final double std_dev_glucose = 61.078835614980584;

  Interpreter? _interpreter;

  bool _isModelLoaded = false;

  double _result = 0.0;

  String _inferenceTime = "";

  List<int>? _inputShape;

  Timer? _timer;

  List<List<double>> hypoglycemicPatientStaticInputs =
  [
    [0.735043, 0.735043, 0.735043, 0.735043, 0.735043], //heart_rate
    [0.0, 0.0, 0.0, 0.0, 0.0], //bolus_dose (short-term insulin dose)
    [0.0, 0.0, 0.0, 0.0, 0.0], //basel_value
    [0.0, 0.0, 0.0, 0.0, 0.0], //meal_carbs
    [1.0, 1.0, 1.0, 1.0, 1.0], //month
    [0.2, 0.2, 0.2, 0.2, 0.2], //day
    [0.086957, 0.086957, 0.086957, 0.130435, 0.130435], //hour
    [0.333333, 0.666667, 1.0, 0.0, 0.333333], //minute
    [0.346764, 0.296703, 0.247863, 0.137973, 0.090354], //gl_value
    [0.0, 0.0, 0.0, 0.0, 0.0] //year
  ];

  // Custom inverse transform function
  double inverseTransform(double value)
  {
    // Replace with your actual min and max values from the training data
    double minValue = 40.0;
    double maxValue = 313.0;
    return value * (maxValue - minValue) + minValue;
  }

  Future<void> loadModel() async
  {
    await localNotification().init(); // initialize local notification

    try
    {
      _interpreter = await Interpreter.fromAsset('lib/assets/GRU_quant.tflite'); // Ensure the path matches

      _inputShape = _interpreter!.getInputTensor(0).shape;

      print("Model input shape: $_inputShape");

      _isModelLoaded = true;

      emit(ModelLoadedSuccessState());

      print("Model loaded successfully.");
      // await localNotification().showPeriodicNotification(
      //     title: "Attention⚠️💊",
      //     body: "Measure Your Glucose Level To be Safe",
      //     payload: "Glucose Level Check");
      // await FlutterRingtonePlayer().play(
      //   fromAsset: "lib/assets/sounds/bell-172780.wav",
      //   volume: 150,
      // ); // will alert the user of glc level by sound
    } catch (e) {
      _isModelLoaded = false;

      emit(ModelLoadedErrorState());
      print("Error loading model: $e");
    }
  }

  Future<void> runInference() async
  {
    if (!_isModelLoaded)
    {
      emit(ModelInferenceErrorState());

      print("Model is not loaded");

      return;
    }

    if (_inputShape == null || _inputShape!.length != 3)
    {
      emit(ModelInferenceErrorState());

      print("Invalid input shape");

      return;
    }

    int batchSize = _inputShape![0];
    int sequenceLength = _inputShape![1];
    int numFeatures = _inputShape![2];

    List<List<double>> staticInputs =
    [
      [0.4612069, 0.4612069, 0.14655172, 0.09051724, 0.11206897], //heart_rate
      [0.0, 0.0, 0.0, 0.0, 0.0], //bolus_dose (short-term insulin dose)
      [0.0, 0.0, 0.33333333, 0.0, 0.0], //basel_value
      [0.0, 0.0, 0.0, 0.0, 0.0], //meal_carbs
      [1.0, 1.0, 1.0, 1.0, 1.0], //month
      [0.16666667, 0.16666667, 0.2, 0.2, 0.2], //day
      [0.95652174, 1.0, 0.0, 0.04347826, 0.08695652], //hour
      [1.0, 0.33333333, 0.0, 1.0, 0.66666667], //minute
      [0.85225885, 0.69474969, 0.12942613, 0.14041514, 0.28693529], //gl_value
      [0.0, 0.0, 0.0, 0.0, 0.0] //year
    ];

    // [64,5,10]

    var input = List.generate(batchSize, (_) {
      return List.generate(sequenceLength, (seqIndex) {
        return List.generate(numFeatures, (featureIndex) {
          return hypoglycemicPatientStaticInputs[featureIndex][seqIndex];
        });
      });
    });

    var outputTensor = List.generate(batchSize, (_) => [0.0]);

    try
    {
      var startTime = DateTime.now().millisecondsSinceEpoch;

      _interpreter!.run(input, outputTensor);

      var endTime = DateTime.now().millisecondsSinceEpoch;

      var inferenceTime = endTime - startTime;

      double predictedGlucoseScaled = outputTensor[0][0];
      double predictedGlucoseDescaled =
      inverseTransform(predictedGlucoseScaled);

      _result = predictedGlucoseDescaled;

      _inferenceTime = "$inferenceTime ms";

      emit(ModelInferenceSuccessState());

        print('predicted hypoglycemia');
        print("Contact Number: $globalEmergencyContactNumber");

        await FlutterRingtonePlayer().play(
          fromAsset: "lib/assets/sounds/bell-172780.wav",
          volume: 150,
        );
        await waitTime(10);

        await localNotification().showNotification(
            title: "Emergency!! ⚠️💊",
            body: "Predicted Low Blood Sugar, take Insulin dose now !!",
            payload: "payload for checking glucose level ");

        await waitTime(10);
        print(globalEmergencyContactNumber);
        print("sending sms.....");

        await directCall();
        print("calling .....");

        await waitTime(5);
        await sendSmsWithLocation();
        print("Prediction: $predictedGlucoseDescaled");

      print("Inference Time: $inferenceTime ms");
    } catch (e) {
      emit(ModelInferenceErrorState());

      print("Error during inference: $e");
    }
  }


  Future<void> getPatientData() async
  {
    FirebaseFirestore.instance
      .collection('users')
      .doc(uId)
      .get()
      .then((DocumentSnapshot documentSnapshot)
      {
        userModel = UserModel.fromJson(documentSnapshot.data() as Map<String, dynamic>);

        emit(GetPatientDataFromDatabaseSuccessState());

      }).catchError((error)
      {
          emit(GetPatientDataFromDatabaseErrorState());
          print(error.toString());
      });
  }

  void setTimerAndRunInference({bool cancelTimer = false})
  {
    if (cancelTimer)
    {
      _timer?.cancel();
      return;
    }

    const duration = Duration(seconds: 15);

    _timer = Timer.periodic(duration, (Timer timer)
    {
      // call the runInference() after the specified duration
      runInference();

      // Reset the timer
      timer.cancel();

      setTimerAndRunInference();
    });
  }
}
