import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hypoglycemia_prediction/models/user_model.dart';
import 'package:hypoglycemia_prediction/modules/blood_glucose_log/cubit/states.dart';
import 'package:hypoglycemia_prediction/shared/components/constants.dart';

class BloodGlucoseLoggingCubit extends Cubit<BloodGlucoseLoggingStates>
{

  BloodGlucoseLoggingCubit() :super(BloodGlucoseLoggingInitialState());

  static BloodGlucoseLoggingCubit get(context) => BlocProvider.of(context);

  String glucoseMeasurementUnit = 'mg/dL';

  List<dynamic>? glucoseReadings;

  void changeMeasurementUnitDropDownList({
    required String measurementUnit,
  })
  {
    glucoseMeasurementUnit = measurementUnit;

    emit(ChangeGlucoseMeasurementUnitDropdownState());
  }

  void updateGlucoseReadings({
    required double glucoseLevel,
    required String currentTime,
  })
  {
    emit(UpdateGlucoseValueLoadingState());

    getGlucoseReadingsFromDatabase()
      .then((value)
      {
        Map<String, dynamic> glucoseReading =
        {
          'glucoseLevel':glucoseLevel,
          'unit':glucoseMeasurementUnit,
          'timeStamp':currentTime,
        };

        glucoseReadings!.add(glucoseReading);

        FirebaseFirestore.instance
          .collection('users')
          .doc(uId)
          .update({
            'glucoseReadings':glucoseReadings,
        }).then((value){

          emit(UpdateGlucoseValueSuccessState());

        }).catchError((error){

          emit(UpdateGlucoseValueErrorState());
        });

      });
  }

  Future<void> getGlucoseReadingsFromDatabase() async
  {
    emit(GetGlucoseReadingsFromDatabaseLoadingState());

    try
    {
      final DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uId)
        .get();

      if(documentSnapshot.exists)
      {
        final UserModel userModel = UserModel.fromJson(documentSnapshot.data() as Map<String, dynamic>);

        glucoseReadings = userModel.glucoseReadings??[];
      }
    }
    catch(error)
    {
      emit(GetGlucoseReadingsFromDatabaseErrorState());
    }

  }

}