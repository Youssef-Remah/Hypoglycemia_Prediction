import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hypoglycemia_prediction/modules/login_page/cubit/states.dart';
import 'package:hypoglycemia_prediction/shared/components/constants.dart';
import 'package:hypoglycemia_prediction/shared/network/local/cache_helper.dart';

class LoginCubit extends Cubit<LoginStates>
{

  LoginCubit() : super(LoginInitialState());

  static LoginCubit get(context) => BlocProvider.of(context);

  bool isPasswordVisible = false;

  void changePasswordVisibility()
  {
    isPasswordVisible = !isPasswordVisible;

    emit(PasswordLoginVisibilityState());
  }

  void userLogin({
    required String email,
    required String password,
  })
  {
    emit(LoginLoadingState());

    FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    ).then((value){

      uId = value.user?.uid;

      CacheHelper.saveData(key: 'userToken', value: uId).then((value){
        emit(LoginSuccessState());
      });

    }).catchError((error){
      emit(LoginErrorState(error.toString()));
      print(error.toString());
    });
  }

}