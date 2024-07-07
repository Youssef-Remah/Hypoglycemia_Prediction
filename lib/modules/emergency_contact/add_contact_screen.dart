import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hypoglycemia_prediction/modules/emergency_contact/cubit/cubit.dart';
import 'package:hypoglycemia_prediction/modules/emergency_contact/cubit/states.dart';
import 'package:hypoglycemia_prediction/shared/components/resuable_components.dart';
import 'package:hypoglycemia_prediction/shared/styles/colors.dart';

class AddContactScreen extends StatelessWidget {
  AddContactScreen({super.key});

  var nameController = TextEditingController();
  var emailController = TextEditingController();
  var numberController = TextEditingController();
  var formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {

    return BlocConsumer<EmergencyContactCubit, EmergencyContactStates>(
      listener: (BuildContext context, state)
      {
        if(state is AddEmergencyContactSuccessState)
        {
          Navigator.pop(context);

          showFlutterToast(
            context: context,
            text: "Contact Added Successfully",
            state: ToastStates.SUCCESS,
          );
        }
      },
      builder: (BuildContext context, Object? state)
      {
        EmergencyContactCubit cubit = EmergencyContactCubit.get(context);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Add Contact'),
            centerTitle: true,
          ),
          body: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                  children:
                  [
                    Form(
                      key: formKey,

                      child: Column(
                        children:
                        [
                          TextFormField(
                              controller: nameController,
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                                labelText: 'Contact Name',
                                prefixIcon: const Icon(Icons.person_outline),
                              ),
                              validator: (String? nameValue)
                              {
                                if(nameValue == null || nameValue.isEmpty)
                                {
                                  return 'Name Must Not be Empty!';
                                }
                                else
                                {
                                  return null;
                                }
                              }
                          ),

                          const SizedBox(height: 15.0,),

                          TextFormField(
                              controller: emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                                labelText: 'Contact Email',
                                prefixIcon: const Icon(Icons.email_outlined),
                              ),
                              validator: (String? emailValue)
                              {
                                if(emailValue == null || emailValue.isEmpty)
                                {
                                  return 'Email Address Must Not be Empty!';
                                }
                                else
                                {
                                  return null;
                                }
                              }
                          ),

                          const SizedBox(height: 15.0),

                          TextFormField(
                            controller: numberController,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              labelText: 'Contact Number',
                              prefixIcon: const Icon(Icons.phone),
                            ),
                            validator: (String? numberValue) {
                              if (numberValue == null || numberValue.isEmpty) {
                                return 'Contact Number Must Not be Empty!';
                              } else {
                                return null;
                              }
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20.0,),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children:
                      [
                        ConditionalBuilder(
                          condition: state is! AddEmergencyContactLoadingState && state is! GetEmergencyContactLoadingState,
                          builder: (BuildContext context) => ElevatedButton(
                            onPressed: ()
                            {
                              if(formKey.currentState?.validate() != null)
                              {
                                cubit.addEmergencyContact(
                                  name: nameController.text,
                                  email: emailController.text,
                                  number: numberController.text,
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: softBlue,
                            ),
                            child: const Text(
                              'Save',
                              style: TextStyle(
                                fontSize: 15.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          fallback: (BuildContext context) => const Center(child: CircularProgressIndicator()),
                        ),

                        const SizedBox(width: 15.0,),

                        ElevatedButton(
                          onPressed: ()
                          {
                            cubit.changePriority();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: (cubit.highestPriority)? Colors.redAccent : softBlue,
                          ),
                          child: Text(
                            (cubit.highestPriority)? 'Highest Priority' : 'Low Priority',
                            style: const TextStyle(
                              fontSize: 15.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ]
              )
          ),
        );
      },
    );
  }
}

