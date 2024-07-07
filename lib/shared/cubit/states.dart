abstract class ModelDeploymentStates {}

class ModelDeploymentInitialState extends ModelDeploymentStates {}

class ModelLoadedSuccessState extends ModelDeploymentStates {}

class ModelLoadedErrorState extends ModelDeploymentStates {}

class ModelInferenceSuccessState extends ModelDeploymentStates {}

class ModelInferenceErrorState extends ModelDeploymentStates {}

class GetPatientDataFromDatabaseSuccessState extends ModelDeploymentStates {}

class GetPatientDataFromDatabaseErrorState extends ModelDeploymentStates {}