import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hypoglycemia_prediction/modules/settings/cubit/cubit.dart';
import 'package:hypoglycemia_prediction/modules/settings/cubit/states.dart';
import 'package:hypoglycemia_prediction/shared/components/resuable_components.dart';

class ICRScreen extends StatelessWidget {
  ICRScreen({super.key});

  var icrCarbUnitsController = TextEditingController();
  var icrInsulinUnitsController = TextEditingController();
  var formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {

    return BlocConsumer<ProfileSettingsCubit, ProfileSettingsStates>(
      listener: (BuildContext context, ProfileSettingsStates state)
      {
        if(state is UpdateICRValuesSuccessState)
        {
          showFlutterToast(
            context: context,
            text: "ICR Units Updates Successfully",
            state: ToastStates.SUCCESS,
          );
        }
      },
      builder: (BuildContext context, ProfileSettingsStates state)
      {
        ProfileSettingsCubit cubit = ProfileSettingsCubit.get(context);

        icrInsulinUnitsController.text = cubit.userModel!.icrInsulinUnits.toString();

        icrCarbUnitsController.text = cubit.userModel!.icrCarbUnits.toString();

        return Scaffold(
          appBar: AppBar(
            title: Text("ICR Configuration"),
          ),

          body: Padding(
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
                        'ICR Values',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20.0,
                        ),
                      ),

                      const SizedBox(height: 15.0,),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children:
                        [
                          SizedBox(
                            width: 150.0,
                            child: TextFormField(
                                controller: icrInsulinUnitsController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5.0),
                                  ),
                                  labelText: 'Insulin units',
                                ),
                                validator: (String? value)
                                {
                                  if(value == null || value.isEmpty)
                                  {
                                    return 'ICR Insulin Unit Must Not be Empty!';
                                  }
                                  else
                                  {
                                    return null;
                                  }
                                }
                            ),
                          ),

                          SizedBox(
                            width: 150.0,
                            child: TextFormField(
                                controller: icrCarbUnitsController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5.0),
                                  ),
                                  labelText: 'Carb units',
                                  suffixText: 'gm',
                                ),
                                validator: (String? value)
                                {
                                  if(value == null || value.isEmpty)
                                  {
                                    return 'ICR Carb Unit Must Not be Empty!';
                                  }
                                  else
                                  {
                                    return null;
                                  }
                                }
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30.0,),

                ConditionalBuilder(
                  condition: state is! UpdateICRValuesLoadingState,
                  builder: (BuildContext context) => ElevatedButton(
                    onPressed: ()
                    {
                      if(formKey.currentState?.validate() != null)
                      {
                        cubit.updateIcrValues(
                          insulinUnits: double.parse(icrInsulinUnitsController.text),
                          carbUnits: double.parse(icrCarbUnitsController.text),
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
    );
  }
}
