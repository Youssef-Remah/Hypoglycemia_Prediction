import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hypoglycemia_prediction/models/meal_model.dart';
import 'package:hypoglycemia_prediction/modules/dietary_manager/add_carbs_screen.dart';
import 'package:hypoglycemia_prediction/modules/dietary_manager/add_meal_screen.dart';
import 'package:hypoglycemia_prediction/modules/dietary_manager/cubit/cubit.dart';
import 'package:hypoglycemia_prediction/modules/dietary_manager/cubit/states.dart';
import 'package:hypoglycemia_prediction/modules/dietary_manager/meal_details_screen.dart';
import 'package:hypoglycemia_prediction/shared/components/constants.dart';
import 'package:hypoglycemia_prediction/shared/components/resuable_components.dart';

class MealsScreen extends StatelessWidget {
  MealsScreen({super.key});

  @override
  Widget build(BuildContext context)
  {
    DietaryManagerCubit.get(context).getIcrUnits();

    DietaryManagerCubit.get(context).patientMeals = [];

    DietaryManagerCubit.get(context).getMealsFromDatabase();

    return BlocConsumer<DietaryManagerCubit, DietaryManagerStates>(
      listener: (BuildContext context, DietaryManagerStates state)
      {
        if(state is DietaryManagerDeleteMealFromDatabaseSuccessState)
        {
          showFlutterToast(
            context: context,
            text: 'Meal Deleted Successfully',
            state: ToastStates.SUCCESS,
          );

          DietaryManagerCubit.get(context).getMealsFromDatabase();
        }
      },

      builder: (BuildContext context, state)
      {
        DietaryManagerCubit cubit = DietaryManagerCubit.get(context);

        return Scaffold(

          appBar: AppBar(
            title: const Text('Dietary Manager'),
            centerTitle: true,
          ),

          body: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children:
              [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    GestureDetector(
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey,
                            width: 2.0,
                          ),
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children:
                          [
                            Image(image: AssetImage('lib/assets/images/icons8-meal-50.png')),

                            Text(
                              'Add Meal',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 17.0,
                              ),
                            )
                          ],
                        ),
                      ),
                      onTap: ()
                      {
                        Navigator.push(
                          context,
                          MaterialPageRoute (
                            builder: (BuildContext context) => AddMealScreen(),
                          ),
                        );
                      },
                    ),

                    GestureDetector(
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey,
                            width: 2.0,
                          ),
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children:
                          [
                            Image(image: AssetImage('lib/assets/images/icons8-carbs-64.png')),

                            Text(
                              'Add Carbs',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 17.0,
                              ),
                            )
                          ],
                        ),
                      ),
                      onTap: ()
                      {
                        Navigator.push(
                          context,
                          MaterialPageRoute (
                            builder: (BuildContext context) => AddCarbsScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 50.0,),


                ConditionalBuilder(
                  condition: state is! DietaryManagerGetMealsFromDatabaseLoadingState,

                  builder: (BuildContext context) => buildMealList(context: context, mealsList: cubit.patientMeals),

                  fallback: (BuildContext context) => const Center(child: CircularProgressIndicator()),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildMealItem({
    required context,
    required String? mealName,
    required String mealId,
  })
  {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0,),
      child: Row(
        children:
        [
          Expanded(
            child: Text(
              mealName!,
              style: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),

          const SizedBox(width: 20.0,),

          IconButton(
            onPressed: ()
            {
              _showDeleteConfirmationDialog(
                context: context,
                mealId: mealId,
              );
            },
            icon: const Icon(Icons.delete),
          ),

          const SizedBox(width: 5.0,),

          IconButton(
              onPressed: ()
              {
                Navigator.push(
                  context,
                  MaterialPageRoute (
                    builder: (BuildContext context) => MealDetailsScreen(mealId: mealId),
                  ),
                );
              },
              icon: const Icon(Icons.arrow_forward_ios_rounded)
          )
        ],
      ),
    );
  }

  Widget buildMealList({
    required context,
    required List<MealModel> mealsList,
  })
  {
    return Expanded(
      child: ListView.separated(
        itemBuilder: (BuildContext context, int index)
        {
          var element = mealsList[index];

          return buildMealItem(
            context: context,
            mealName: element.mealName,
            mealId: element.mealId!,
          );
        },
        separatorBuilder: (BuildContext context, int index) => const Divider(),
        itemCount: mealsList.length,
      ),
    );
  }

  void _showDeleteConfirmationDialog({
    required BuildContext context,
    required String mealId,
  })
  {
    showDialog(
      context: context,
      builder: (BuildContext context)
      {
        return AlertDialog(
          title: const Text("Confirm Delete"),
          content: const Text("Are you sure you want to delete this meal ?"),
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
                DietaryManagerCubit.get(context).deleteMealFromDatabase(mealId: mealId);
                Navigator.of(context).pop();
              },
              child: const Text("Delete"),
            ),
          ]
        );
      },
    );
  }
}
