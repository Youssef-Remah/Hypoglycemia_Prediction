import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hypoglycemia_prediction/modules/settings/cubit/cubit.dart';
import 'package:hypoglycemia_prediction/modules/settings/cubit/states.dart';
import 'package:hypoglycemia_prediction/shared/components/constants.dart';
import 'package:hypoglycemia_prediction/shared/components/resuable_components.dart';

class AccountDetailsScreen extends StatelessWidget {
  AccountDetailsScreen({super.key});

  var formKey = GlobalKey<FormState>();

  var userNameController = TextEditingController();

  var phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {

    ProfileSettingsCubit cubit =  ProfileSettingsCubit.get(context);

    return BlocConsumer<ProfileSettingsCubit, ProfileSettingsStates>(

      listener: (BuildContext context, ProfileSettingsStates state)
      {

        if(state is UpdateUserAccountDetailsSuccessState)
        {
          showFlutterToast(
            context: context,
            text: "Account Details Updated Successfully",
            state: ToastStates.SUCCESS,
          );
        }

      },
      builder: (BuildContext context, ProfileSettingsStates state)
      {

        userNameController.text = cubit.userModel!.name!;
        phoneController.text = cubit.userModel!.phone!;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Account Details'),
          ),

          body: ConditionalBuilder(
            condition: state is! GetUserDataFromDatabaseLoadingState,

            builder: (BuildContext context)
            {
              return Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  children:
                  [
                    Form(
                      key: formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children:
                        [
                          const Text(
                            'User Name',
                            style: TextStyle(
                              fontSize: 17.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 10.0,),

                          TextFormField(
                            controller: userNameController,
                            keyboardType: TextInputType.name,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20.0),
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

                          const SizedBox(height: 35.0,),

                          const Text(
                            'Mobile Number',
                            style: TextStyle(
                              fontSize: 17.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 10.0,),

                          TextFormField(
                            controller: phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              labelText: 'Mobile Number',
                              prefixIcon: const Icon(Icons.phone),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30.0,),

                    ConditionalBuilder(
                      condition: state is! UpdateUserAccountDetailsLoadingState,

                      builder: (BuildContext context)
                      {
                        return ElevatedButton(
                          onPressed: ()
                          {
                            if(formKey.currentState?.validate() != null)
                            {
                              _showUpdateConfirmationDialog(
                                context: context,
                                uId: uId,
                                userName: userNameController.text,
                                userPhone: phoneController.text,
                              );
                            }
                          },
                          child: const Text('Save'),
                        );
                      },

                      fallback: (BuildContext context) => const Center(child: CircularProgressIndicator()),
                    ),
                  ],
                ),
              );
            },

            fallback: (BuildContext context) => const Center(child: CircularProgressIndicator()),
          ),
        );
      },
    );
  }


  void _showUpdateConfirmationDialog({
    required BuildContext context,
    required String? uId,
    required String userName,
    required String userPhone,
  })
  {
    showDialog(
      context: context,
      builder: (BuildContext context)
      {
        return AlertDialog(
            title: const Text("Confirm Update"),
            content: const Text("Are you sure you want to Update your Account Details?"),
            actions:
            [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("Cancel"),
              ),

              TextButton(
                onPressed: () {

                  ProfileSettingsCubit.get(context).updateUserAccountDetails(
                    uId: uId,
                    name: userName,
                    phone: userPhone,
                  );

                  Navigator.of(context).pop();
                },
                child: const Text("Update"),
              ),
            ]
        );
      },
    );
  }
}
