class MealModel
{
  String? mealId;

  String? mealName;

  List<dynamic>? ingredients;

  MealModel({
    required this.mealId,
    required this.mealName,
    required this.ingredients,
  });

  MealModel.fromJson(Map<String, dynamic> json)
  {
    mealId = json['mealId'];
    mealName = json['mealName'];
    ingredients = json['ingredients'];
  }

  Map<String, dynamic> toMap()
  {
    return
      {
        'mealId':mealId,

        'mealName':mealName,

        'ingredients':ingredients,
      };
  }
}