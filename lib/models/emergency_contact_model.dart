class EmergencyContactModel
{
  String? contactName;

  String? contactEmail;

  String? contactNumber;

  bool? isHighestPriority;

  String? contactId;

  EmergencyContactModel({
    required this.contactName,
    required this.contactEmail,
    required this.contactNumber,
    this.contactId,
    this.isHighestPriority,
  });

  EmergencyContactModel.fromJson(Map<String, dynamic> json)
  {
    contactName = json['contactName'];
    contactEmail = json['contactEmail'];
    contactNumber = json['contactNumber'];
    contactId = json['contactId'];
    isHighestPriority = json['isHighestPriority'];
  }

  Map<String, dynamic> toMap()
  {
    return
      {
        'contactName': contactName,

        'contactEmail': contactEmail,

        'contactNumber': contactNumber,

        'contactId': contactId,

        'isHighestPriority': isHighestPriority,
      };
  }

}
