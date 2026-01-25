import 'package:equatable/equatable.dart';

abstract class KnockoutEvent extends Equatable {
  const KnockoutEvent();

  @override
  List<Object> get props => [];
}

class KnockoutRequested extends KnockoutEvent {
  final int leagueId;
  final int season;

  const KnockoutRequested(this.leagueId, this.season);

  @override
  List<Object> get props => [leagueId, season];
}
