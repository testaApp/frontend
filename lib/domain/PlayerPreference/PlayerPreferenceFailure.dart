class PlayerPreferenceFailure {
  final String message;

  PlayerPreferenceFailure(this.message);

  @override
  String toString() {
    return 'PlayerPreferenceFailure: $message';
  }
}

class PlayerPreferenceNotFoundFailure extends PlayerPreferenceFailure {
  PlayerPreferenceNotFoundFailure() : super('Player preference not found');
}

class PlayerPreferenceCreationFailure extends PlayerPreferenceFailure {
  PlayerPreferenceCreationFailure()
      : super('Failed to create player preference');
}

class PlayerPreferenceUpdateFailure extends PlayerPreferenceFailure {
  PlayerPreferenceUpdateFailure() : super('Failed to update player preference');
}

class PlayerPreferenceDeletionFailure extends PlayerPreferenceFailure {
  PlayerPreferenceDeletionFailure()
      : super('Failed to delete player preference');
}

class ServerErrorsFailure extends PlayerPreferenceFailure {
  ServerErrorsFailure() : super('Server error occurred');
}

class NetworkErrorFailure extends PlayerPreferenceFailure {
  NetworkErrorFailure() : super('Network error occurred');
}
