import 'package:blogapp/features/news/pages/news/transfer_news/top_transfer/transfer/transfer_model.dart';

enum TransferStatus {
  initial,
  loading,
  success,
  failure,
}

class TransferState {
  const TransferState({
    this.transfers = const [],
    this.status = TransferStatus.initial,
    this.pageNumber = 1,
    this.isLastPage = false,
    this.isLoadingMore = false,
    this.errorMessage,
  });

  final List<TransferModel> transfers;
  final TransferStatus status;
  final int pageNumber;
  final bool isLastPage;
  final bool isLoadingMore;
  final String? errorMessage;

  TransferState copyWith({
    List<TransferModel>? transfers,
    int? pageNumber,
    TransferStatus? status,
    bool? isLastPage,
    bool? isLoadingMore,
    String? errorMessage,
  }) {
    return TransferState(
      transfers: transfers ?? this.transfers,
      status: status ?? this.status,
      pageNumber: pageNumber ?? this.pageNumber,
      isLastPage: isLastPage ?? this.isLastPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
