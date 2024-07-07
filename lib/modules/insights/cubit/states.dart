abstract class InsightsStates {}

class InsightsInitialState extends InsightsStates {}

class GetGlucoseFromDatabaseLoadingState extends InsightsStates {}

class GetGlucoseFromDatabaseSuccessState extends InsightsStates {}

class GetGlucoseFromDatabaseErrorState extends InsightsStates {}

class EmptyGlucoseHistoryState extends InsightsStates {}