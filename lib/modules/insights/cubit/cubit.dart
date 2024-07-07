import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hypoglycemia_prediction/models/user_model.dart';
import 'package:hypoglycemia_prediction/modules/insights/cubit/states.dart';
import 'package:hypoglycemia_prediction/shared/components/constants.dart';

class InsightsCubit extends Cubit<InsightsStates>
{
  UserModel? userModel;

  InsightsCubit() :super(InsightsInitialState());

  static InsightsCubit get(context) => BlocProvider.of(context);

  Future<void> getGlucoseData() async
  {
    emit(GetGlucoseFromDatabaseLoadingState());

    FirebaseFirestore.instance
      .collection('users')
      .doc(uId)
      .get()
      .then((DocumentSnapshot documentSnapshot)
      {
        userModel = UserModel.fromJson(documentSnapshot.data() as Map<String, dynamic>);

        if(userModel!.glucoseReadings == null || userModel!.glucoseReadings!.isEmpty)
        {
          emit(EmptyGlucoseHistoryState());
        }

        else
        {
          emit(GetGlucoseFromDatabaseSuccessState());
        }
      }).catchError((error)
      {
        emit(GetGlucoseFromDatabaseErrorState());
        print(error.toString());
      });
  }


}