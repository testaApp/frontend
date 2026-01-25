import 'package:equatable/equatable.dart';

abstract class TeamProfileStandingEvent extends Equatable {
  const TeamProfileStandingEvent();
}

class TeamStandingRequested extends TeamProfileStandingEvent {
  final int teamId;

  TeamStandingRequested({required this.teamId});

  @override
  List<Object?> get props => [teamId];
}
