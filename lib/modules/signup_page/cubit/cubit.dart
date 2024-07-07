import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hypoglycemia_prediction/models/user_model.dart';
import 'package:hypoglycemia_prediction/modules/signup_page/cubit/states.dart';
import 'package:hypoglycemia_prediction/shared/components/constants.dart';
import 'package:hypoglycemia_prediction/shared/network/local/cache_helper.dart';

class SignupCubit extends Cubit<SignupStates>
{

  SignupCubit() : super(SignupInitialState());

  static SignupCubit get(context) => BlocProvider.of(context);

  bool isPasswordVisible = false;

  void changePasswordVisibility()
  {
    isPasswordVisible = !isPasswordVisible;

    emit(PasswordSignupVisibilityState());
  }

  void userCreate({
    required String? name,
    required String? email,
    required String? phone,
    required String? uId,
  })
  {
    UserModel model = UserModel(
      name: name,
      email: email,
      phone: phone,
      uId: uId,
      carbIntakes: null,
      shortTermInsulinDoses: null,
      glucoseReadings: null,
      icrInsulinUnits: 1.0,
      icrCarbUnits: 15.0,
      heartRateReadings: null,
      basalInsulinDoses: null,
      distanceCoveredReadings: null,
      stepsCoveredReadings: null,
      caloriesBurntReadings: null,
    );
    
    FirebaseFirestore.instance
      .collection('users')
      .doc(uId)
      .set(model.toMap()).
    then((value){

      CacheHelper.saveData(key: 'userToken', value: uId).then((value){
        emit(CreateUserSuccessState());
      });

    }).
    catchError((error){
      emit(CreateUserErrorState(error.toString()));
    });
  }

  void userRegister({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) {
    emit(SignupLoadingState());

    FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    ).then((value) {
      value.user?.sendEmailVerification().then((_) {
        emit(SignupSuccessState('A verification email has been sent to $email. Please verify your email to continue.'));

        // Check email verification status
        checkEmailVerification(
          name: name,
          email: email,
          phone: phone,
          userId: value.user?.uid,
        );
      }).catchError((error) {
        emit(SignupErrorState(error.toString()));
      });
    }).catchError((error) {
      emit(SignupErrorState(error.toString()));
    });
  }


  void checkEmailVerification({
    required String name,
    required String email,
    required String phone,
    required String? userId,
  }) async {
    const timeout = Duration(minutes: 3);
    final endTime = DateTime.now().add(timeout);

    Timer.periodic(const Duration(seconds: 3), (timer) async {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.reload();
        user = FirebaseAuth.instance.currentUser;

        if (user!.emailVerified) {
          timer.cancel();

          // Create the user in Firestore only after email verification
          userCreate(
            name: name,
            email: email,
            phone: phone,
            uId: userId,
          );

          uId = userId;
        } else if (DateTime.now().isAfter(endTime))
        {
          timer.cancel();

          emit(SignupErrorState('Email verification timed out.'));
        }
      }
      else {
        timer.cancel();
        emit(SignupErrorState('Failed to reload user.'));
      }
    });
  }



}