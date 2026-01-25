import 'transfer_model.dart';

enum Transferstatus {
  requested,
  requestFailed,
  requestSuccess,
  failed,
  unknown,
}

class TransferState {
  TransferState(
      {this.Transfer = const [],
      this.status = Transferstatus.unknown,
      this.pageNumber = 1,
      this.isLastPage = false,
      this.loading = false});

  List<TransferModel> Transfer;
  Transferstatus status;
  int pageNumber;
  bool isLastPage;
  bool loading;
  TransferState copyWith(
          {List<TransferModel>? Transfer,
          int? pageNumber,
          Transferstatus? status,
          bool? isLastPage,
          bool? loading}) =>
      TransferState(
          Transfer: Transfer ?? this.Transfer,
          status: status ?? this.status,
          pageNumber: pageNumber ?? this.pageNumber,
          isLastPage: isLastPage ?? this.isLastPage,
          loading: loading ?? this.loading);
}
