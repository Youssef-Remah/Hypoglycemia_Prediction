import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hypoglycemia_prediction/modules/dietary_manager/cubit/cubit.dart';
import 'package:hypoglycemia_prediction/modules/dietary_manager/cubit/states.dart';
import 'package:hypoglycemia_prediction/shared/components/resuable_components.dart';
import 'package:hypoglycemia_prediction/shared/styles/colors.dart';

class SearchIngredientScreen extends StatelessWidget {
  SearchIngredientScreen({super.key});

  var searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DietaryManagerCubit, DietaryManagerStates>(

      listener: (BuildContext context, DietaryManagerStates state)
      {
        if(state is DietaryManagerDuplicatedIngredientState)
        {
          showFlutterToast(
            context: context,
            text: 'Ingredient Already Added',
            state: ToastStates.WARNING,
          );
        }

        if(state is DietaryManagerAddSelectedIngredientState)
        {
          showFlutterToast(
            context: context,
            text: 'Ingredient Added',
            state: ToastStates.SUCCESS,
          );
        }
      },
      builder: (BuildContext context, DietaryManagerStates state)
      {
        DietaryManagerCubit cubit = DietaryManagerCubit.get(context);

        return Scaffold(

          appBar: AppBar(
            title: const Text('Search Ingredient'),
            centerTitle: true,
          ),

          body: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children:
              [
                TextFormField(
                  controller: searchController,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    labelText: 'Search for an Ingredient',
                    prefixIcon: const Icon(Icons.search_rounded),
                  ),
                  onFieldSubmitted: (String value)
                  {
                    cubit.searchIngredient(ingredientName: value.toLowerCase());
                  },
                ),

                const SizedBox(height: 30.0,),

                ConditionalBuilder(
                  condition: state is! DietaryManagerIngredientSearchLoadingState,
                  builder: (BuildContext context) => buildIngredientList(
                    ingredientsList: cubit.ingredientsSearchList,
                    cubit: cubit,
                    context: context,
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

  Widget buildIngredientItem({
    required Map<String, dynamic> ingredient,
    required DietaryManagerCubit cubit,
    required context,
  })
  {
    return Row(
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

        ElevatedButton(
          onPressed: ()
          {
            cubit.addSelectedIngredient(ingredientItem: ingredient);

            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: softBlue,
          ),
          child: const Text(
            'Add to Meal',
            style: TextStyle(
              fontSize: 15.0,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildIngredientList({
    required List<Map<String, dynamic>> ingredientsList,
    required DietaryManagerCubit cubit,
    required context,
  })
  {
    return Expanded(
      child: ListView.separated(
        itemBuilder: (BuildContext context, int index) => buildIngredientItem(
          context: context,
          cubit: cubit,
          ingredient: ingredientsList[index],
        ),
        separatorBuilder: (BuildContext context, int index) => const Divider(thickness: 1.2,),
        itemCount: ingredientsList.length,
      ),
    );
  }
}
