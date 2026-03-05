import 'package:blogapp/models/standings/standings.dart';

enum SeasonsPageStatus { initial, loading, loaded, error }

class SeasonsPageState {
  List<List<List<TableItem>>> winners;
  SeasonsPageStatus status;
  SeasonsPageState({
    this.winners = const [],
    this.status = SeasonsPageStatus.initial,
  });

  SeasonsPageState copyWith({
    List<List<List<TableItem>>>? winners,
    SeasonsPageStatus? status,
  }) {
    return SeasonsPageState(
      winners: winners ?? this.winners,
      status: status ?? this.status,
    );
  }
}
