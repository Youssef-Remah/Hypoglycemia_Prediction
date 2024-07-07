import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hypoglycemia_prediction/modules/dietary_manager/cubit/cubit.dart';
import 'package:hypoglycemia_prediction/modules/dietary_manager/cubit/states.dart';
import 'package:hypoglycemia_prediction/shared/components/constants.dart';
import 'package:hypoglycemia_prediction/shared/components/resuable_components.dart';
import 'package:hypoglycemia_prediction/shared/styles/colors.dart';

class AddCarbsScreen extends StatelessWidget {
  AddCarbsScreen({super.key});

  var carbIntakeController = TextEditingController();
  var formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DietaryManagerCubit, DietaryManagerStates>(

      listener: (BuildContext context, DietaryManagerStates state)
      {
        if(state is DietaryManagerUpdateCarbSuccessState)
        {
          showFlutterToast(
            context: context,
            text: "Carbohydrate Intake Logged Successfully",
            state: ToastStates.SUCCESS,
          );
        }
      },
      builder: (BuildContext context, DietaryManagerStates state)
      {
        DietaryManagerCubit cubit = DietaryManagerCubit.get(context);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Add Carbohydrates'),
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: ()
              {
                cubit.currentShortTermInsulinDose = 0.0;

                Navigator.pop(context);
              }
            ),
          ),

          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children:
                [
                  Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:
                      [
                        TextFormField(
                            controller: carbIntakeController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              labelText: 'Carbs Amount',
                              suffixText: 'gm',
                            ),
                            validator: (String? value)
                            {
                              if(value == null || value.isEmpty)
                              {
                                return 'Carbs Intake Must Not be Empty!';
                              }
                              else
                              {
                                return null;
                              }
                            }
                        ),

                        const SizedBox(height: 30.0,),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30.0,),

                  ConditionalBuilder(
                    condition: state is! DietaryManagerUpdateCarbLoadingState,
                    builder: (BuildContext context) => Container(
                      height: 150.0,
                      width: 300.0,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey,
                          width: 1.5,
                        ),
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children:
                        [
                          const Text(
                            'Calculated Insulin',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.0,
                            ),
                          ),

                          Text(
                            '${cubit.currentShortTermInsulinDose} units/mL',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    fallback: (BuildContext context) => const Center(child: CircularProgressIndicator()),
                  ),

                  const SizedBox(height: 30.0,),

                  ConditionalBuilder(
                    condition: state is! DietaryManagerUpdateCarbLoadingState &&
                      state is! DietaryManagerGetCarbIntakesAndShortTermInsulinFromDatabaseLoadingState,

                    builder: (BuildContext context) => ElevatedButton(
                      onPressed: ()
                      {
                        if(formKey.currentState?.validate() != null)
                        {
                          cubit.updateCarbohydrateIntakeAndShortTermInsulin(
                            carbIntake: double.parse(carbIntakeController.text),
                            timeStamp: getCurrentTime(),
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
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
