enum SetPreferenceStatus { initial, loading, success, failure, unauthorized }

class SetPreferenceState {
  SetPreferenceStatus status;
  SetPreferenceState({this.status = SetPreferenceStatus.initial});
  SetPreferenceState copyWith({
    SetPreferenceStatus? status,
  }) {
    return SetPreferenceState(
      status: status ?? this.status,
    );
  }
}
