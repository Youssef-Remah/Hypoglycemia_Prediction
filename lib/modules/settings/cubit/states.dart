abstract class ProfileSettingsStates {}

class ProfileSettingsInitialState extends ProfileSettingsStates {}

class UserProfileSignOutSuccessState extends ProfileSettingsStates {}

class GetUserDataFromDatabaseLoadingState extends ProfileSettingsStates {}

class GetUserDataFromDatabaseSuccessState extends ProfileSettingsStates {}

class GetUserDataFromDatabaseErrorState extends ProfileSettingsStates {}

class UpdateUserAccountDetailsLoadingState extends ProfileSettingsStates {}

class UpdateUserAccountDetailsSuccessState extends ProfileSettingsStates {}

class UpdateUserAccountDetailsErrorState extends ProfileSettingsStates {}

class UpdateICRValuesLoadingState extends ProfileSettingsStates {}

class UpdateICRValuesSuccessState extends ProfileSettingsStates {}

class UpdateICRValuesErrorState extends ProfileSettingsStates {}

class GetICRValuesSuccessState extends ProfileSettingsStates {}

class GetICRValuesErrorState extends ProfileSettingsStates {}