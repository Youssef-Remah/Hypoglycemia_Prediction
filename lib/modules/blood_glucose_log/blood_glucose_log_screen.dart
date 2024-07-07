import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hypoglycemia_prediction/modules/blood_glucose_log/cubit/cubit.dart';
import 'package:hypoglycemia_prediction/modules/blood_glucose_log/cubit/states.dart';
import 'package:hypoglycemia_prediction/shared/components/constants.dart';
import 'package:hypoglycemia_prediction/shared/components/resuable_components.dart';

class BloodGlucoseLogScreen extends StatelessWidget {
  BloodGlucoseLogScreen({super.key});

  var bloodGlucoseController = TextEditingController();

  var formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => BloodGlucoseLoggingCubit(),

      child: BlocConsumer<BloodGlucoseLoggingCubit, BloodGlucoseLoggingStates>(
        listener: (BuildContext context, BloodGlucoseLoggingStates state)
        {
          if(state is UpdateGlucoseValueSuccessState)
          {
            showFlutterToast(
              context: context,
              text: 'Blood Glucose Value Saved',
              state: ToastStates.SUCCESS,
            );
          }

          if(state is UpdateGlucoseValueErrorState)
          {
            showFlutterToast(
              context: context,
              text: 'An Error occurred, please try again!',
              state: ToastStates.ERROR,
            );
          }
        },

        builder: (BuildContext context, BloodGlucoseLoggingStates state)
        {
          BloodGlucoseLoggingCubit cubit = BloodGlucoseLoggingCubit.get(context);

          return Scaffold(
            appBar: AppBar(
              title: const Text('Blood Glucose Input'),
            ),

            body: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children:
                [
                  const Text(
                    'Save Your BG Level Manually',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                      fontSize: 17.0,
                    ),
                  ),

                  const SizedBox(
                    height: 20.0,
                  ),

                  Form(
                    key: formKey,

                    child: Row(
                      children:
                      [
                        Expanded(
                          child: TextFormField(
                              controller: bloodGlucoseController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                                labelText: 'Blood Glucose',
                                prefixIcon: const Icon(Icons.bloodtype_rounded),
                              ),
                              validator: (String? glucoseValue)
                              {
                                if(glucoseValue == null || glucoseValue.isEmpty)
                                {
                                  return 'Blood glucose value Must Not be Empty!';
                                }
                                else
                                {
                                  return null;
                                }
                              }
                          ),
                        ),

                        const SizedBox(
                          width: 30.0,
                        ),

                        buildMeasurementUnitDropDown(context: context),
                      ],
                    ),
                  ),

                  const SizedBox(
                    height: 30.0,
                  ),

                  ConditionalBuilder(
                    condition: state is! UpdateGlucoseValueLoadingState && state is! GetGlucoseReadingsFromDatabaseLoadingState,
                    builder: (BuildContext context) => Center(
                      child: ElevatedButton(
                        onPressed: ()
                        {
                          if(formKey.currentState?.validate() != null)
                          {
                            cubit.updateGlucoseReadings(
                              glucoseLevel: double.parse(bloodGlucoseController.text),
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

  Widget buildMeasurementUnitDropDown({
    required context,
  })
  {
    return DropdownButton<String>(
      value: BloodGlucoseLoggingCubit.get(context).glucoseMeasurementUnit,
      onChanged: (String? value) {
        BloodGlucoseLoggingCubit.get(context).changeMeasurementUnitDropDownList(measurementUnit: value!);
      },
      items: <String>['mg/dL', 'mmol/L']
        .map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
      }).toList(),
    );
  }
}
