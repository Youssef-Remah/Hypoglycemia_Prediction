import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hypoglycemia_prediction/models/user_model.dart';
import 'package:hypoglycemia_prediction/modules/basal_insulin_log/cubit/states.dart';
import 'package:hypoglycemia_prediction/shared/components/constants.dart';

class BasalInsulinLoggingCubit extends Cubit<BasalInsulinLoggingStates>
{
  BasalInsulinLoggingCubit() :super(BasalInsulinInitialState());

  static BasalInsulinLoggingCubit get(context) => BlocProvider.of(context);

  List<dynamic>? basalDoses = [];

  void updateBasalInsulinDose({
    required double basalInsulinDose,
    required String currentTime,
  })
  {
    emit(BasalInsulinDoseUpdateLoadingState());

    getBasalInsulinDosesFromDatabase()
      .then((value)
      {
        Map<String, dynamic> doseWithTimeStamp = {'basalDose':basalInsulinDose, 'timeStamp':currentTime};

        basalDoses!.add(doseWithTimeStamp);

        FirebaseFirestore.instance
          .collection('users')
          .doc(uId)
          .update({
            'basalInsulinDoses': basalDoses,
          }).then((value)
          {

            emit(BasalInsulinDoseUpdateSuccessState());

          }).catchError((error)
          {
            print(error.toString());
            emit(BasalInsulinDoseUpdateErrorState());
          });
      });
  }

  Future<void> getBasalInsulinDosesFromDatabase() async
  {
    emit(GetBasalInsulinDosesFromDatabaseLoadingState());

    try
    {
      final DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uId)
        .get();

      if(documentSnapshot.exists)
      {
        final UserModel userModel = UserModel.fromJson(documentSnapshot.data() as Map<String, dynamic>);

        basalDoses = userModel.basalInsulinDoses??[];
      }
    }
    catch(error)
    {
      emit(GetBasalInsulinDosesFromDatabaseErrorState());
    }

  }

}