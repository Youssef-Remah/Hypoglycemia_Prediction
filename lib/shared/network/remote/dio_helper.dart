import 'package:dio/dio.dart';

class DioHelper{

  static late Dio mealDio;

  static mealInitApi(){
    mealDio = Dio(
        BaseOptions(
          baseUrl: 'https://api.spoonacular.com/',
          receiveDataWhenStatusError: true,
        )
    );
  }



  static Future<Response> searchIngredientData({
    required String url,
    required Map<String, dynamic> parameters
  })async {
    return await mealDio.get(url, queryParameters: parameters);
  }

  static Future<Response> getIngredientInformation({
    required String url,
    required Map<String, dynamic> parameters
  })async {
    return await mealDio.get(url, queryParameters: parameters);
  }

}