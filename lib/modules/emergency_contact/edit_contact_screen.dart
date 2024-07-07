import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hypoglycemia_prediction/modules/emergency_contact/cubit/cubit.dart';
import 'package:hypoglycemia_prediction/modules/emergency_contact/cubit/states.dart';
import 'package:hypoglycemia_prediction/shared/components/resuable_components.dart';
import 'package:hypoglycemia_prediction/shared/styles/colors.dart';

class EditContactScreen extends StatelessWidget {
  EditContactScreen({
    super.key,
    required this.contactId,
  });

  final String? contactId;

  Map<String, dynamic>? contactDetails;

  var nameController = TextEditingController();
  var emailController = TextEditingController();
  var numberController = TextEditingController();
  var formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    EmergencyContactCubit.get(context)
        .getSingleEmergencyContact(contactId: contactId);

    return BlocConsumer<EmergencyContactCubit, EmergencyContactStates>(
      listener: (BuildContext context, state) {
        if (state is GetSingleEmergencyContactSuccessState) {
          contactDetails =
              EmergencyContactCubit.get(context).singleContactModel?.toMap();
          nameController.text = contactDetails?['contactName'];
          emailController.text = contactDetails?['contactEmail'];
          numberController.text = contactDetails?['contactNumber'];
        }

        if (state is UpdateSingleEmergencyContactSuccessState) {
          showFlutterToast(
            context: context,
            text: "User Details Updated Successfully",
            state: ToastStates.SUCCESS,
          );

          Navigator.pop(context);
        }

        if (state is DeleteSingleEmergencyContactSuccessState) {
          showFlutterToast(
            context: context,
            text: "User Deleted Successfully",
            state: ToastStates.SUCCESS,
          );

          Navigator.pop(context);
        }
      },
      builder: (BuildContext context, Object? state) {
        EmergencyContactCubit cubit = EmergencyContactCubit.get(context);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Edit Contacts'),
            centerTitle: true,
          ),
          body: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(children: [
                Form(
                  key: formKey,
                  child: Column(
                    children: [
                      TextFormField(
                          controller: nameController,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 15.0, horizontal: 10.0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            labelText: 'Contact Name',
                            prefixIcon: const Icon(Icons.person_outline),
                          ),
                          validator: (String? nameValue) {
                            if (nameValue == null || nameValue.isEmpty) {
                              return 'Name Must Not be Empty!';
                            } else {
                              return null;
                            }
                          }),
                      const SizedBox(
                        height: 15.0,
                      ),
                      TextFormField(
                          controller: emailController,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 15.0, horizontal: 10.0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            labelText: 'Contact Email',
                            prefixIcon: const Icon(Icons.email_outlined),
                          ),
                          validator: (String? emailValue) {
                            if (emailValue == null || emailValue.isEmpty) {
                              return 'Email Address Must Not be Empty!';
                            } else {
                              return null;
                            }
                          }),
                      const SizedBox(height: 15.0),
                      TextFormField(
                        controller: numberController,
                        // Use the new controller
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 15.0, horizontal: 10.0),
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
                const SizedBox(
                  height: 20.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ConditionalBuilder(
                      condition:
                      state is! UpdateSingleEmergencyContactLoadingState,
                      builder: (BuildContext context) => ElevatedButton(
                        onPressed: () {
                          if (formKey.currentState?.validate() != null) {
                            cubit.updateSingleEmergencyContact(
                              contactId: contactId,
                              newName: nameController.text,
                              newEmail: emailController.text,
                              newNumber:
                              numberController.text, // Pass the new number
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
                      fallback: (BuildContext context) =>
                      const Center(child: CircularProgressIndicator()),
                    ),
                    const SizedBox(
                      width: 30.0,
                    ),
                    ConditionalBuilder(
                      condition:
                      state is! DeleteSingleEmergencyContactLoadingState,
                      builder: (BuildContext context) => ElevatedButton(
                        onPressed: () {
                          if (formKey.currentState?.validate() != null) {
                            cubit.deleteSingleEmergencyContact(
                                contactId: contactId);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: softBlue,
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.delete),
                            SizedBox(
                              width: 10.0,
                            ),
                            Text(
                              'Delete',
                              style: TextStyle(
                                fontSize: 15.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      fallback: (BuildContext context) =>
                      const Center(child: CircularProgressIndicator()),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20.0,
                ),
                ElevatedButton(
                  onPressed: (cubit.contactList.length == 1)
                      ? null
                      : () {
                    cubit.changePriority();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                    (cubit.highestPriority) ? Colors.redAccent : softBlue,
                  ),
                  child: Text(
                    (cubit.highestPriority)
                        ? 'Highest Priority'
                        : 'Low Priority',
                    style: const TextStyle(
                      fontSize: 15.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ])),
        );
      },
    );
  }
}
