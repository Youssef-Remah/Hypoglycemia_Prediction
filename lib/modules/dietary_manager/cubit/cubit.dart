import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hypoglycemia_prediction/models/meal_model.dart';
import 'package:hypoglycemia_prediction/models/user_model.dart';
import 'package:hypoglycemia_prediction/modules/dietary_manager/cubit/states.dart';
import 'package:hypoglycemia_prediction/shared/components/constants.dart';
import 'package:hypoglycemia_prediction/shared/network/remote/dio_helper.dart';

class DietaryManagerCubit extends Cubit<DietaryManagerStates>
{

  DietaryManagerCubit():super(DietaryManagerInitialState());

  static DietaryManagerCubit get(context) => BlocProvider.of(context);

  double currentShortTermInsulinDose = 0.0;

  double mealTotalCarbAmount = 0.0;

  String mealName = '';

  double ingredientAmount = 0.0;

  List<Map<String, dynamic>> ingredientsSearchList = [];

  List<dynamic> selectedIngredients = [];

  List<MealModel> patientMeals = [];

  UserModel? userModel;

  List<dynamic>? shortTermInsulinDoses;

  List<dynamic>? carbohydrateIntakes;


  void updateCarbohydrateIntakeAndShortTermInsulin({
    required double carbIntake,
    required String timeStamp,
  })
  {
    emit(DietaryManagerUpdateCarbLoadingState());

    // ICR = Total grams of carbohydrates / Insulin dose in units

    // Insulin dose = (grams of carbohydrates) / (grams of carbohydrates per unit of insulin)

    double insulinUnits = userModel!.icrInsulinUnits!;

    double carbUnits = userModel!.icrCarbUnits!;


    double ICR = carbUnits / insulinUnits;

    currentShortTermInsulinDose = carbIntake / ICR;


    currentShortTermInsulinDose = double.parse(currentShortTermInsulinDose.toStringAsFixed(3));

    carbIntake = double.parse(carbIntake.toStringAsFixed(3));

    getCarbIntakesAndShortTermInsulinFromDatabase()
      .then((value)
      {

        shortTermInsulinDoses!.add
        ({
          'shortTermInsulinDose':currentShortTermInsulinDose,
          'timeStamp':timeStamp,
        });

        carbohydrateIntakes!.add
        ({
          'carbIntake':carbIntake,
          'timeStamp':timeStamp,
        });

        FirebaseFirestore.instance
            .collection('users')
            .doc(uId)
            .update({
          'carbIntakes': carbohydrateIntakes,
          'shortTermInsulinDoses': shortTermInsulinDoses,
        }).then((value){
          emit(DietaryManagerUpdateCarbSuccessState());
        }).catchError((error){
          emit(DietaryManagerUpdateCarbErrorState());
        });

      });
  }

  void clearAllMealData()
  {
    currentShortTermInsulinDose = 0.0;

    mealTotalCarbAmount = 0.0;

    ingredientsSearchList = [];

    selectedIngredients = [];
  }

  Future<void> getCarbIntakesAndShortTermInsulinFromDatabase() async
  {
    emit(DietaryManagerGetCarbIntakesAndShortTermInsulinFromDatabaseLoadingState());

    try
    {
      final DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uId)
        .get();

      if(documentSnapshot.exists)
      {
        final UserModel userModel = UserModel.fromJson(documentSnapshot.data() as Map<String, dynamic>);

        carbohydrateIntakes = userModel.carbIntakes??[];

        shortTermInsulinDoses = userModel.shortTermInsulinDoses??[];
      }
    }
    catch(error)
    {
      emit(DietaryManagerGetCarbIntakesAndShortTermInsulinFromDatabaseErrorState());
    }

  }

  void searchIngredient({
    required String? ingredientName,
  })
  {
    emit(DietaryManagerIngredientSearchLoadingState());

    DioHelper.searchIngredientData(
      url: 'food/ingredients/search',
      parameters:
      {
        'query': ingredientName,
        'number': 60,
        'apiKey': '3b1b6426da5548d783772dc45579d0f2',
      },
    ).then((value){

      emit(DietaryManagerIngredientSearchSuccessState());

      ingredientsSearchList = [];

      for(var element in value.data['results'])
      {
        ingredientsSearchList.add(element);
      }

    }).catchError((error){
      emit(DietaryManagerIngredientSearchErrorState());
      print(error.toString());
    });
  }

  void addSelectedIngredient({
    required Map<String, dynamic> ingredientItem,
  })
  {
    if(selectedIngredients.isNotEmpty)
    {
      for(var element in selectedIngredients)
      {
        if(element['id'] == ingredientItem['id'])
        {
          emit(DietaryManagerDuplicatedIngredientState());
          return;
        }
      }

      ingredientItem['amount'] = 0.0;

      selectedIngredients.add(ingredientItem);

      emit(DietaryManagerAddSelectedIngredientState());
    }
    else
    {
      ingredientItem['amount'] = 0.0;

      selectedIngredients.add(ingredientItem);

      emit(DietaryManagerAddSelectedIngredientState());
    }

  }

  void clearSelectedIngredient({
    required int id,
  })
  {
    for(var element in selectedIngredients)
    {
      if(element['id'] == id)
      {
        selectedIngredients.remove(element);
        break;
      }
    }

    emit(DietaryManagerClearSelectedIngredientState());
  }

  void addAmountToIngredient({
    required int id,
    required double amount,
  })
  {

    for(var element in selectedIngredients)
    {
      if(element['id'] == id)
      {
        element['amount'] = amount;
        break;
      }
    }

    emit(DietaryManagerAddAmountToIngredientState());
  }

  bool checkForIngredientsAmount()
  {
    for(var element in selectedIngredients)
    {
      if(element['amount'] == 0.0)
      {
        return false;
      }
    }
    return true;
  }

  void getIngredientInfo()
  {

    emit(DietaryManagerGetIngredientInformationLoadingState());

    mealTotalCarbAmount = 0.0;

    List<Future> futures = [];

    for(var element in selectedIngredients)
    {
      Future future = DioHelper.getIngredientInformation(
        url: 'food/ingredients/${element['id']}/information',
        parameters:
        {
          'amount': element['amount'],
          'unit': 'grams',
          'apiKey': '3b1b6426da5548d783772dc45579d0f2',
        },
      ).then((value){
        for(var element in value.data['nutrition']['nutrients'])
        {
          if(element['name'] == "Net Carbohydrates")
          {
            mealTotalCarbAmount += element['amount'];
            break;
          }
        }
      }).catchError((error){
        emit(DietaryManagerGetIngredientInformationErrorState());
      });

      futures.add(future);
    }

    Future.wait(futures).then((_) {
      emit(DietaryManagerGetIngredientInformationSuccessState());
    });
  }

  void addMealToDatabase({
    required String mealName,
  })
  {
    emit(DietaryManagerAddMealToDatabaseLoadingState());

    MealModel model = MealModel(
      mealId: null,
      mealName: mealName,
      ingredients: selectedIngredients,
    );

    FirebaseFirestore.instance
        .collection('users')
        .doc(uId)
        .collection('meals')
        .add(model.toMap()).then((DocumentReference doc){

          String docId = doc.id;

      doc.update({'mealId':docId}).then((value){
        emit(DietaryManagerAddMealToDatabaseSuccessState());
      });
    }).catchError((error){
      emit(DietaryManagerAddMealToDatabaseErrorState());
      print(error.toString());
    });
  }

  void getMealsFromDatabase()
  {
    emit(DietaryManagerGetMealsFromDatabaseLoadingState());

    FirebaseFirestore.instance
        .collection('users')
        .doc(uId)
        .collection('meals')
        .get()
        .then((QuerySnapshot querySnapshot)
    {

      if (querySnapshot.docs.isNotEmpty)
      {

        patientMeals = [];

        for (var doc in querySnapshot.docs)
        {
          patientMeals.add(MealModel.fromJson(doc.data() as Map<String, dynamic>));
        }

        emit(DietaryManagerGetMealsFromDatabaseSuccessState());
      }

      else
      {
        emit(DietaryManagerEmptyMealsInDatabaseState());
      }

    }).catchError((error){
      emit(DietaryManagerGetMealsFromDatabaseErrorState());
      print(error.toString());
    });
  }

  void getSingleMealDetails({
    required String mealId,
  })
  {
    emit(DietaryManagerGetSingleMealFromDatabaseLoadingState());

    FirebaseFirestore.instance
        .collection('users')
        .doc(uId)
        .collection('meals')
        .doc(mealId)
        .get().then((DocumentSnapshot documentSnapshot){

      emit(DietaryManagerGetSingleMealFromDatabaseSuccessState());

      MealModel model = MealModel.fromJson(documentSnapshot.data() as Map<String, dynamic>);

      selectedIngredients = model.ingredients!;
      mealName = model.mealName!;

    }).catchError((error){
      emit(DietaryManagerGetSingleMealFromDatabaseErrorState());
      print(error.toString());

    });
  }

  void getIngredientAmount({
    required int id,
  })
  {
    for(var element in selectedIngredients)
    {
      if(element['id'] == id)
      {
        ingredientAmount = element['amount'];
        return;
      }
    }
  }

  void updateAndLoggMeal({
    required String mealId,
    required String mealName,
  })
  {
    emit(DietaryManagerUpdateMealDetailsLoadingState());

    FirebaseFirestore.instance
        .collection('users')
        .doc(uId)
        .collection('meals')
        .doc(mealId).update({
      'mealName':mealName,
      'ingredients':selectedIngredients,
    }).then((value){
      emit(DietaryManagerUpdateMealDetailsSuccessState());
    }).catchError((error){
      emit(DietaryManagerUpdateMealDetailsErrorState());
    });
  }

  void deleteMealFromDatabase({
    required String mealId,
  })
  {
    emit(DietaryManagerDeleteMealFromDatabaseLoadingState());

    FirebaseFirestore.instance
        .collection('users')
        .doc(uId)
        .collection('meals')
        .doc(mealId).delete().then((value){
      emit(DietaryManagerDeleteMealFromDatabaseSuccessState());
    }).catchError((error){
      emit(DietaryManagerDeleteMealFromDatabaseErrorState());
      print(error.toString());
    });
  }

  void getIcrUnits()
  {
    FirebaseFirestore.instance
      .collection('users')
      .doc(uId)
      .get().then((DocumentSnapshot documentSnapshot){

      userModel = UserModel.fromJson(documentSnapshot.data() as Map<String, dynamic>);

      emit(DietaryManagerGetIcrUnitsFromDatabaseSuccessState());

    }).catchError((error){

      emit(DietaryManagerGetIcrUnitsFromDatabaseErrorState());
      print(error.toString());
    });
  }

}