abstract class EmergencyContactStates {}

class EmergencyContactInitialState extends EmergencyContactStates {}

class AddEmergencyContactLoadingState extends EmergencyContactStates {}

class AddEmergencyContactSuccessState extends EmergencyContactStates {}

class AddEmergencyContactErrorState extends EmergencyContactStates {}

class GetEmergencyContactSuccessState extends EmergencyContactStates {}

class GetEmergencyContactLoadingState extends EmergencyContactStates {}

class GetEmergencyContactErrorState extends EmergencyContactStates {}

class EmptyEmergencyContactInDatabaseState extends EmergencyContactStates {}

class GetSingleEmergencyContactLoadingState extends EmergencyContactStates {}

class GetSingleEmergencyContactSuccessState extends EmergencyContactStates {}

class GetSingleEmergencyContactErrorState extends EmergencyContactStates {}

class UpdateSingleEmergencyContactLoadingState extends EmergencyContactStates {}

class UpdateSingleEmergencyContactSuccessState extends EmergencyContactStates {}

class UpdateSingleEmergencyContactErrorState extends EmergencyContactStates {}

class DeleteSingleEmergencyContactLoadingState extends EmergencyContactStates {}

class DeleteSingleEmergencyContactSuccessState extends EmergencyContactStates {}

class DeleteSingleEmergencyContactErrorState extends EmergencyContactStates {}

class ChangeContactPriorityState extends EmergencyContactStates {}

class PriorityModificationErrorState extends EmergencyContactStates {}