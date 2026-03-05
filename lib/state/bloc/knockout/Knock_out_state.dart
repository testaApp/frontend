import 'package:equatable/equatable.dart';

enum KnockoutStatus {
  initial,
  requestInProgress,
  requestSuccess,
  requestFailure
}

class KnockoutState extends Equatable {
  final KnockoutStatus status;
  final Map<String, dynamic> championsLeague;
  final String error;

  const KnockoutState({
    this.status = KnockoutStatus.initial,
    this.championsLeague = const {},
    this.error = '',
  });

  KnockoutState copyWith({
    KnockoutStatus? status,
    Map<String, dynamic>? championsLeague,
    String? error,
  }) {
    return KnockoutState(
      status: status ?? this.status,
      championsLeague: championsLeague ?? this.championsLeague,
      error: error ?? this.error,
    );
  }

  @override
  List<Object> get props => [status, championsLeague, error];
}
