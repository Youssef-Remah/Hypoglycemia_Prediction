import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hypoglycemia_prediction/models/user_model.dart';
import 'package:hypoglycemia_prediction/modules/settings/cubit/states.dart';
import 'package:hypoglycemia_prediction/modules/welcome_page/welcome_screen.dart';
import 'package:hypoglycemia_prediction/shared/components/constants.dart';
import 'package:hypoglycemia_prediction/shared/network/local/cache_helper.dart';

class ProfileSettingsCubit extends Cubit<ProfileSettingsStates>
{

  ProfileSettingsCubit() : super(ProfileSettingsInitialState());

  static ProfileSettingsCubit get(context) => BlocProvider.of(context);

  UserModel? userModel;

  void signOut({
    required context,
  })
  {
    CacheHelper.removeData(key: 'userToken').then((value)
    {
      CacheHelper.removeData(key: 'globalEmergencyContactNumber').then((value)
      {
        emit(UserProfileSignOutSuccessState());

        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute (builder: (BuildContext context) => WelcomeScreen()),
                (route) => false
        );
      });
    });
  }

  void getUserDataFromDatabase()
  {
    emit(GetUserDataFromDatabaseLoadingState());

    FirebaseFirestore.instance
      .collection('users')
      .doc(uId)
      .get().then((DocumentSnapshot documentSnapshot){

        userModel = UserModel.fromJson(documentSnapshot.data() as Map<String, dynamic>);

        emit(GetUserDataFromDatabaseSuccessState());

    }).catchError((error){

      emit(GetUserDataFromDatabaseErrorState());
      print(error.toString());
    });
  }

  void updateUserAccountDetails({
    required String? uId,
    required String name,
    required String phone,
  })
  {
    emit(UpdateUserAccountDetailsLoadingState());

    FirebaseFirestore.instance
      .collection('users')
      .doc(uId)
      .update({
      'name':name,
      'phone':phone,
    }).then((value){

      emit(UpdateUserAccountDetailsSuccessState());

    }).catchError((error){

      emit(UpdateUserAccountDetailsErrorState());
    });
  }

  void updateIcrValues({
    required double insulinUnits,
    required double carbUnits,
  })
  {
    emit(UpdateICRValuesLoadingState());

    FirebaseFirestore.instance
      .collection('users')
      .doc(uId)
      .update({
        'icrInsulinUnits':insulinUnits,
        'icrCarbUnits':carbUnits,
      }).then((value)
    {

      emit(UpdateICRValuesSuccessState());

    }).catchError((error){

      emit(UpdateICRValuesErrorState());
    });
  }

}