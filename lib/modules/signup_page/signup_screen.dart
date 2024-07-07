import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hypoglycemia_prediction/modules/home_page/home_screen.dart';
import 'package:hypoglycemia_prediction/modules/signup_page/cubit/cubit.dart';
import 'package:hypoglycemia_prediction/modules/signup_page/cubit/states.dart';
import 'package:hypoglycemia_prediction/shared/components/constants.dart';
import 'package:hypoglycemia_prediction/shared/components/resuable_components.dart';


class SignupScreen extends StatelessWidget {
  SignupScreen({super.key});

  var formKey = GlobalKey<FormState>();

  var emailController = TextEditingController();

  var passwordController = TextEditingController();

  var phoneController = TextEditingController();

  var nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {

    return BlocProvider(

      create: (BuildContext context) => SignupCubit(),

      child: BlocConsumer<SignupCubit, SignupStates>(

        listener: (BuildContext context, SignupStates state)
        {
          if(state is SignupErrorState)
          {
            showFlutterToast(
              context: context,
              text: state.error,
              state: ToastStates.ERROR,
            );
          }

          if(state is CreateUserErrorState)
          {
            showFlutterToast(
              context: context,
              text: state.error,
              state: ToastStates.ERROR,
            );
          }

          if(state is CreateUserSuccessState)
          {
            // modelDeploymentCubit.loadModel().then((value){
            //   modelDeploymentCubit.runInference();
            // });

            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute (
                builder: (BuildContext context) => const HomeScreen(),
              ),
                  (route) => false,
            );
          }

          if(state is SignupSuccessState)
          {
            showFlutterToast(
              context: context,
              text: state.message,
              state: ToastStates.WARNING,
              textColor: Colors.black,
            );
          }

        },

        builder: (BuildContext context, SignupStates state)
        {
          SignupCubit cubit = SignupCubit.get(context);

          return Scaffold(

            appBar: AppBar(
              title: const Text("Sign Up"),
              backgroundColor: Colors.greenAccent,
            ),

            body: SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18.0),
                      child: Column(
                        children:
                        [
                          const SizedBox(
                            height: 280.0,
                            child: Image(
                              image: AssetImage("lib/assets/images/signup_5977603.png")
                          ),
                        ),

                          const SizedBox(
                            height: 20.0,
                          ),

                          Form(
                            key: formKey,

                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children:
                              [
                                const SizedBox(
                                  height: 20.0,
                                ),

                                TextFormField(
                                  controller: nameController,
                                  keyboardType: TextInputType.name,
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(25.0),
                                    ),
                                    labelText: 'User Name',
                                    prefixIcon: const Icon(Icons.person),
                                  ),
                                  validator: (String? nameValue)
                                  {
                                    if(nameValue == null || nameValue.isEmpty)
                                    {
                                      return 'User Name field must not be empty !';
                                    }
                                    else
                                    {
                                      return null;
                                    }
                                  },
                                ),

                                const SizedBox(
                                  height: 20.0,
                                ),

                                TextFormField(
                                  controller: emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(25.0),
                                    ),
                                    labelText: 'Email',
                                    prefixIcon: const Icon(Icons.email_rounded),
                                  ),
                                  validator: (String? emailValue)
                                  {
                                    if(emailValue == null || emailValue.isEmpty)
                                    {
                                      return 'Email field must not be empty !';
                                    }
                                    else
                                    {
                                      return null;
                                    }
                                  },
                                ),

                                const SizedBox(
                                  height: 20.0,
                                ),

                                TextFormField(
                                  controller: phoneController,
                                  keyboardType: TextInputType.phone,
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(25.0),
                                    ),
                                    labelText: 'Phone Number',
                                    prefixIcon: const Icon(Icons.phone),
                                  ),
                                ),

                                const SizedBox(
                                  height: 20.0,
                                ),

                                TextFormField(
                                  controller: passwordController,
                                  keyboardType: TextInputType.visiblePassword,
                                  obscureText: cubit.isPasswordVisible? false : true,
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(25.0),
                                    ),
                                    labelText: 'Password',
                                    prefixIcon: const Icon(Icons.lock),
                                    suffixIcon: IconButton(
                                      onPressed: ()
                                      {
                                        cubit.changePasswordVisibility();
                                      },
                                      icon: Icon(cubit.isPasswordVisible? Icons.visibility : Icons.visibility_off),
                                    ),
                                  ),
                                  validator: (String? passwordValue)
                                  {
                                    if(passwordValue == null || passwordValue.isEmpty)
                                    {
                                      return 'Password is too short !';
                                    }
                                    else
                                    {
                                      return null;
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(
                              height: 35.0
                          ),

                          ConditionalBuilder(
                            condition: state is! SignupLoadingState, 
                            builder: (BuildContext context) => Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30.0),
                                  color: Colors.lightGreenAccent
                              ),
                              width: 250.0,
                              child: MaterialButton(
                                onPressed: ()
                                {
                                  if(formKey.currentState!.validate())
                                  {
                                    cubit.userRegister(
                                      name: nameController.text,
                                      email: emailController.text,
                                      password: passwordController.text,
                                      phone: phoneController.text,
                                    );
                                  }
                                },
                                child: Text(
                                  "Create an account",
                                  style: GoogleFonts.robotoCondensed(
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold,color: Colors.black87
                                  ),
                                ),
                              ),
                            ),
                            fallback: (BuildContext context) => const Center(child: CircularProgressIndicator()),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
            ),
          );
        },
      ),
    );
  }
}
