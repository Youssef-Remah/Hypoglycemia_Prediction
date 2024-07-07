import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hypoglycemia_prediction/modules/home_page/home_screen.dart';
import 'package:hypoglycemia_prediction/modules/login_page/cubit/cubit.dart';
import 'package:hypoglycemia_prediction/modules/login_page/cubit/states.dart';
import 'package:hypoglycemia_prediction/shared/components/constants.dart';
import 'package:hypoglycemia_prediction/shared/components/resuable_components.dart';
import 'package:hypoglycemia_prediction/shared/network/local/cache_helper.dart';

class LoginScreen extends StatelessWidget {

  var formKey = GlobalKey<FormState>();

  var emailController = TextEditingController();

  var passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {

    return BlocProvider(

      create: (BuildContext context) => LoginCubit(),

      child: BlocConsumer<LoginCubit, LoginStates>(

        listener: (BuildContext context, LoginStates state)
        {
          if(state is LoginErrorState)
          {
            showFlutterToast(
              context: context,
              text: state.error.toString(),
              state: ToastStates.ERROR,
            );
          }

          if(state is LoginSuccessState)
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
        },

        builder: (BuildContext context, LoginStates state)
        {
          LoginCubit cubit = LoginCubit.get(context);

          return Scaffold(

            appBar: AppBar(
              title: const Text("Login"),
            ),

            body: SafeArea(

              child: Center(

                child: SingleChildScrollView(

                  child: Padding(
                    padding: const EdgeInsets.all(20.0),

                    child: Column(
                      children:
                      [
                        const SizedBox(
                            height: 200.0,
                            child:
                            Image(image: AssetImage("lib/assets/images/data.png"))
                        ),

                        const SizedBox(
                          height: 20.0,
                        ),

                        Text(
                          "Sign In 👇",
                          style: GoogleFonts.robotoCondensed(
                            fontSize: 30.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(
                          height: 10.0,
                        ),

                        Text(
                          "Nice To Meet You, Hero 😃",
                          style: GoogleFonts.robotoCondensed(fontSize: 19),
                        ),

                        const SizedBox(
                          height: 25.0,
                        ),

                        Form(
                          key: formKey,

                          child: Column(
                            children:
                            [
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
                                height: 25.0,
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
                          height: 35.0,
                        ),

                        ConditionalBuilder(
                          condition: state is! LoginLoadingState,
                          builder: (BuildContext context) => Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: Colors.lightBlueAccent
                            ),
                            width: 250.0,
                            child: MaterialButton(
                              onPressed: ()
                              {
                                if (formKey.currentState!.validate())
                                {
                                  cubit.userLogin(
                                    email: emailController.text,
                                    password: passwordController.text,
                                  );

                                }
                              },
                              child: Text(
                                "Log In Now",
                                style: GoogleFonts.robotoCondensed(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
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
              ),
            ),
          );
        },
      ),
    );
  }
}
