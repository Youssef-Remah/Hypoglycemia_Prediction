import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hypoglycemia_prediction/modules/dietary_manager/cubit/cubit.dart';
import 'package:hypoglycemia_prediction/modules/dietary_manager/cubit/states.dart';
import 'package:hypoglycemia_prediction/modules/dietary_manager/ingredient_details_update_screen.dart';
import 'package:hypoglycemia_prediction/modules/dietary_manager/search_ingredient_screen.dart';
import 'package:hypoglycemia_prediction/shared/components/constants.dart';
import 'package:hypoglycemia_prediction/shared/components/resuable_components.dart';
import 'package:hypoglycemia_prediction/shared/styles/colors.dart';

class MealDetailsScreen extends StatelessWidget {

  MealDetailsScreen({
    super.key,
    required this.mealId,
  });

  final String mealId;

  var mealNameController = TextEditingController();
  var mealNameFormKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {

    DietaryManagerCubit.get(context).getSingleMealDetails(mealId: mealId);

    return BlocConsumer<DietaryManagerCubit, DietaryManagerStates>(

      listener: (BuildContext context, DietaryManagerStates state)
      {
        if(state is DietaryManagerGetSingleMealFromDatabaseSuccessState)
        {
          mealNameController.text = DietaryManagerCubit.get(context).mealName;
        }

        if(state is DietaryManagerGetIngredientInformationSuccessState)
        {
          DietaryManagerCubit.get(context).updateCarbohydrateIntakeAndShortTermInsulin(
            carbIntake: DietaryManagerCubit.get(context).mealTotalCarbAmount,
            timeStamp: getCurrentTime(),
          );
        }

        if(state is DietaryManagerUpdateCarbSuccessState)
        {
          DietaryManagerCubit.get(context).updateAndLoggMeal(mealId: mealId, mealName: mealNameController.text);
        }

        if(state is DietaryManagerUpdateMealDetailsSuccessState)
        {
          showFlutterToast(
            context: context,
            text: 'Meal Updated Successfully',
            state: ToastStates.SUCCESS,
          );

          DietaryManagerCubit.get(context).getMealsFromDatabase();
        }
      },

      builder: (BuildContext context, DietaryManagerStates state)
      {
        DietaryManagerCubit cubit = DietaryManagerCubit.get(context);

        return Scaffold(

          appBar: AppBar(
            title: const Text('Update Meal'),
            centerTitle: true,
            actions:
            [
              IconButton(
                onPressed: ()
                {
                  Navigator.push(
                    context,
                    MaterialPageRoute (
                      builder: (BuildContext context) => SearchIngredientScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.search_rounded),
              ),
            ],
            leading: IconButton(
              onPressed: ()
              {
                Navigator.pop(context);

                DietaryManagerCubit.get(context).clearAllMealData();
              },
              icon: const Icon(Icons.arrow_back),
            ),
          ),

          body: ConditionalBuilder(
            condition: state is! DietaryManagerGetSingleMealFromDatabaseLoadingState,
            builder: (BuildContext context) => Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children:
                [
                  ConditionalBuilder(
                    condition: cubit.selectedIngredients.isNotEmpty,

                    builder: (BuildContext context) => buildSelectedIngredientList(
                      context: context,
                      cubit: cubit,
                      selectedIngredientsList: cubit.selectedIngredients,
                    ),

                    fallback: (BuildContext context) => const Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children:
                        [
                          Image(image: AssetImage('lib/assets/images/search_ingredient.png')),

                          SizedBox(height: 20.0,),

                          Text(
                            'Looking for ingredients? Tap the "Search" icon to begin.',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Container(
                    height: 200.0,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey,
                        width: 1.5,
                      ),
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children:
                      [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children:
                          [
                            Text(
                              'Carbs',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16.0,
                              ),
                            ),

                            Text(
                              'Insulin',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16.0,
                              ),
                            ),
                          ],
                        ),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children:
                          [
                            Text(
                              '${cubit.mealTotalCarbAmount} gm',
                              style: const TextStyle(
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

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children:
                          [
                            ConditionalBuilder(
                              condition: state is! DietaryManagerUpdateMealDetailsLoadingState &&
                              state is! DietaryManagerUpdateCarbLoadingState &&
                              state is! DietaryManagerGetCarbIntakesAndShortTermInsulinFromDatabaseLoadingState,

                              builder: (BuildContext context) => ElevatedButton(
                                onPressed: ()
                                {
                                  if(mealNameFormKey.currentState?.validate() != null)
                                  {
                                    if(cubit.selectedIngredients.isNotEmpty)
                                    {
                                      if(cubit.checkForIngredientsAmount())
                                      {

                                        cubit.getIngredientInfo();

                                      }
                                      else
                                      {
                                        showFlutterToast(
                                          context: context,
                                          text: 'One or more ingredients do not have an amount !',
                                          state: ToastStates.WARNING,
                                        );
                                      }

                                    }
                                    else
                                    {
                                      showFlutterToast(
                                        context: context,
                                        text: 'Please add some ingredients to the meal !',
                                        state: ToastStates.WARNING,
                                      );
                                    }
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: softBlue,
                                ),
                                child: const Text(
                                  'Update & Logg Meal',
                                  style: TextStyle(
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),

                              fallback: (BuildContext context) => const CircularProgressIndicator(),
                            ),

                            Form(
                              key: mealNameFormKey,
                              child: SizedBox(
                                width: 100.0,
                                child: TextFormField(
                                    controller: mealNameController,
                                    keyboardType: TextInputType.text,
                                    decoration: const InputDecoration(
                                      contentPadding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 0.0),
                                      labelText: 'Meal Name',
                                    ),
                                    validator: (String? nameValue)
                                    {
                                      if(nameValue == null || nameValue.isEmpty)
                                      {
                                        return 'Required Field !';
                                      }
                                      else
                                      {
                                        return null;
                                      }
                                    }
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            fallback: (BuildContext context) => const Center(child: CircularProgressIndicator()),
          ),
        );
      },
    );
  }


  Widget buildSelectedIngredientItem({
    required context,
    required Map<String, dynamic> ingredient,
    required DietaryManagerCubit cubit,
  })
  {
    return Dismissible(
      key: Key(ingredient['id'].toString()),
      onDismissed: (direction){
        cubit.clearSelectedIngredient(id: ingredient['id']);
      },
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          children:
          [
            SizedBox(
              width: 80.0,
              height: 80.0,
              child: Image(image: NetworkImage('https://spoonacular.com/cdn/ingredients_100x100/${ingredient['image']}'))
            ),

            const SizedBox(width: 15.0,),

            Expanded(
              child: Text(
                '${ingredient['name']}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                ),
              ),
            ),

            IconButton(
                onPressed: ()
                {
                  Navigator.push(
                    context,
                    MaterialPageRoute (
                      builder: (BuildContext context) => IngredientDetailsUpdateScreen(ingredientId: ingredient['id'],),
                    ),
                  );
                },
                icon: const Icon(Icons.arrow_forward_ios_rounded)
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSelectedIngredientList({
    required context,
    required List<dynamic> selectedIngredientsList,
    required DietaryManagerCubit cubit,
  })
  {
    return Expanded(
      child: ListView.separated(
        itemBuilder: (BuildContext context, int index) => buildSelectedIngredientItem(
          context: context,
          ingredient: selectedIngredientsList[index],
          cubit: cubit,
        ),
        separatorBuilder: (BuildContext context, int index) => const Divider(thickness: 1.2,),
        itemCount: selectedIngredientsList.length,
      ),
    );
  }

}
