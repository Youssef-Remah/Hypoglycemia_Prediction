class MedicationModel
{
  String? medicationId;

  String? medicationName;

  double? medicationUnit;

  String? medicationFrequency;

  String? medicationTime;

  MedicationModel({
    required this.medicationId,
    required this.medicationName,
    required this.medicationUnit,
    required this.medicationFrequency,
    required this.medicationTime,
  });

  MedicationModel.fromJson(Map<String, dynamic> json)
  {
    medicationId = json['medicationId'];
    medicationName = json['medicationName'];
    medicationUnit = json['medicationUnit'];
    medicationFrequency = json['medicationFrequency'];
    medicationTime = json['medicationTime'];
  }

  Map<String, dynamic> toMap()
  {
    return
      {
        'medicationId':medicationId,

        'medicationName':medicationName,

        'medicationUnit':medicationUnit,

        'medicationFrequency':medicationFrequency,

        'medicationTime':medicationTime,
      };
  }

}