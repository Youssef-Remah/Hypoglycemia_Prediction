import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hypoglycemia_prediction/modules/dietary_manager/cubit/cubit.dart';
import 'package:hypoglycemia_prediction/modules/dietary_manager/cubit/states.dart';
import 'package:hypoglycemia_prediction/shared/components/resuable_components.dart';
import 'package:hypoglycemia_prediction/shared/styles/colors.dart';

class IngredientDetailsScreen extends StatelessWidget {
  IngredientDetailsScreen({
    super.key,
    required this.ingredientId,
  });

  final int ingredientId;
  var ingredientAmountController = TextEditingController();
  var formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DietaryManagerCubit, DietaryManagerStates>(

      listener: (BuildContext context, DietaryManagerStates state){},

      builder: (BuildContext context, DietaryManagerStates state)
      {
        DietaryManagerCubit cubit = DietaryManagerCubit.get(context);

        return Scaffold(

          appBar: AppBar(
            title: const Text('Ingredient Amount'),
            centerTitle: true,
          ),

          body: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children:
              [
                Form(
                  key: formKey,
                  child: TextFormField(
                      controller: ingredientAmountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        labelText: 'Ingredient Amount',
                        suffixText: 'gm',
                      ),
                      validator: (String? value)
                      {
                        if(value == null || value.isEmpty)
                        {
                          return 'Ingredient Amount Must Not be Empty!';
                        }
                        else
                        {
                          return null;
                        }
                      }
                  ),
                ),

                const SizedBox(height: 20.0,),

                ElevatedButton(
                  onPressed: ()
                  {
                    if(formKey.currentState?.validate() != null)
                    {
                      cubit.addAmountToIngredient(
                        id: ingredientId,
                        amount: double.parse(ingredientAmountController.text),
                      );

                      showFlutterToast(
                        context: context,
                        text: 'Amount Added',
                        state: ToastStates.SUCCESS,
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
              ],
            ),
          ),
        );
      },
    );
  }
}
