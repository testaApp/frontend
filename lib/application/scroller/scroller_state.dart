class ScrollerState {
  final bool? displayWidget;

  ScrollerState({this.displayWidget = true});
  ScrollerState copyWith({final bool? displayWidget}) =>
      ScrollerState(displayWidget: displayWidget ?? this.displayWidget);
}
