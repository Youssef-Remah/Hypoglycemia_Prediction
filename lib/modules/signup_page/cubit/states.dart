abstract class SignupStates {}

class SignupInitialState extends SignupStates {}

class PasswordSignupVisibilityState extends SignupStates {}

class SignupLoadingState extends SignupStates {}

class SignupSuccessState extends SignupStates
{
  final String message;

  SignupSuccessState(this.message);
}

class SignupErrorState extends SignupStates
{
  final String error;

  SignupErrorState(this.error);
}

class CreateUserSuccessState extends SignupStates {}

class CreateUserErrorState extends SignupStates
{
  final String error;

  CreateUserErrorState(this.error);
}