class UserModel
{

  //Metadata Fields
  String? name;
  String? email;
  String? phone;
  String? uId;        // User ID

  //Health Fields
  List<dynamic>? heartRateReadings;           // Heart rate in beats per minute (BPM)
  List<dynamic>? distanceCoveredReadings;      // Distance covered in (meters)
  List<dynamic>? stepsCoveredReadings;               // Number of steps taken
  List<dynamic>? caloriesBurntReadings;       // Calories burnt during activity
  List<dynamic>? glucoseReadings;     // Glucose level in the blood

  //Medical Fields
  List<dynamic>? shortTermInsulinDoses;       // Short-term insulin dose
  List<dynamic>? basalInsulinDoses;              // Basal insulin doses with time stamp for each dose
  double? icrInsulinUnits;            // Insulin-to-carb ratio in insulin units
  double? icrCarbUnits;               // Insulin-to-carb ratio in carbohydrate units

  //Other Fields
  List<dynamic>? carbIntakes;                 // Carbohydrate intake in grams


  UserModel({
    required this.name,
    required this.email,
    required this.phone,
    required this.uId,
    required this.carbIntakes,
    required this.shortTermInsulinDoses,
    required this.basalInsulinDoses,
    required this.glucoseReadings,
    required this.icrInsulinUnits,
    required this.icrCarbUnits,
    required this.heartRateReadings,
    required this.distanceCoveredReadings,
    required this.stepsCoveredReadings,
    required this.caloriesBurntReadings,
  });

  UserModel.fromJson(Map<String, dynamic> json)
  {
    name = json['name'];
    email = json['email'];
    phone = json['phone'];
    uId = json['uId'];
    carbIntakes = json['carbIntakes'];
    shortTermInsulinDoses = json['shortTermInsulinDoses'];
    basalInsulinDoses = json['basalInsulinDoses'];
    glucoseReadings = json['glucoseReadings'];
    icrInsulinUnits = json['icrInsulinUnits'];
    icrCarbUnits = json['icrCarbUnits'];
    heartRateReadings = json['heartRateReadings'];
    distanceCoveredReadings = json['distanceCoveredReadings'];
    stepsCoveredReadings = json['stepsCoveredReadings'];
    caloriesBurntReadings = json['caloriesBurntReadings'];
  }

  Map<String, dynamic> toMap()
  {
    return
    {
      'name':name,
      'email':email,
      'phone':phone,
      'uId':uId,
      'carbIntakes':carbIntakes,
      'shortTermInsulinDoses':shortTermInsulinDoses,
      'basalInsulinDoses':basalInsulinDoses,
      'glucoseReadings':glucoseReadings,
      'icrInsulinUnits':icrInsulinUnits,
      'icrCarbUnits':icrCarbUnits,
      'heartRateReadings':heartRateReadings,
      'distanceCoveredReadings':distanceCoveredReadings,
      'stepsCoveredReadings':stepsCoveredReadings,
      'caloriesBurntReadings':caloriesBurntReadings,
    };
  }

}