import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hypoglycemia_prediction/modules/basal_insulin_log/cubit/cubit.dart';
import 'package:hypoglycemia_prediction/modules/basal_insulin_log/cubit/states.dart';
import 'package:hypoglycemia_prediction/shared/components/constants.dart';
import 'package:hypoglycemia_prediction/shared/components/resuable_components.dart';

class BasalInsulinLogScreen extends StatelessWidget {
  BasalInsulinLogScreen({super.key});

  var basalInsulinController = TextEditingController();

  var formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => BasalInsulinLoggingCubit(),

      child: BlocConsumer<BasalInsulinLoggingCubit, BasalInsulinLoggingStates>(

        listener: (BuildContext context, BasalInsulinLoggingStates state)
        {
          if(state is BasalInsulinDoseUpdateSuccessState)
          {
            showFlutterToast(
              context: context,
              text: 'Basal Insulin Dose Saved',
              state: ToastStates.SUCCESS,
            );
          }

          if(state is BasalInsulinDoseUpdateErrorState)
          {
            showFlutterToast(
              context: context,
              text: 'An Error occurred, please try again!',
              state: ToastStates.ERROR,
            );
          }
        },

        builder: (BuildContext context, BasalInsulinLoggingStates state)
        {
          BasalInsulinLoggingCubit cubit = BasalInsulinLoggingCubit.get(context);

          return Scaffold(
            appBar: AppBar(
              title: const Text('Basal Insulin Input'),
            ),

            body: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                children:
                [
                  Form(
                    key: formKey,

                    child: Column(
                      children:
                      [
                        TextFormField(
                            controller: basalInsulinController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              labelText: 'Basal Insulin Dose (Units)',
                              prefixIcon: const Icon(Icons.medication),
                            ),
                            validator: (String? insulinValue)
                            {
                              if(insulinValue == null || insulinValue.isEmpty)
                              {
                                return 'Insulin value Must Not be Empty!';
                              }
                              else
                              {
                                return null;
                              }
                            }
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                    height: 25.0,
                  ),

                  ConditionalBuilder(
                    condition: state is! GetBasalInsulinDosesFromDatabaseLoadingState && state is! BasalInsulinDoseUpdateLoadingState,
                    builder: (BuildContext context) => ElevatedButton(
                      onPressed: ()
                      {
                        if(formKey.currentState!.validate())
                        {
                          cubit.updateBasalInsulinDose(
                            basalInsulinDose: double.parse(basalInsulinController.text),
                            currentTime: getCurrentTime(),
                          );
                        }
                      },
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
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
