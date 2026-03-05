import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;

import 'package:blogapp/core/network/baseUrl.dart';
import 'package:blogapp/features/news/pages/news/transfer_news/top_transfer/transfer/transfer_event.dart';
import 'package:blogapp/features/news/pages/news/transfer_news/top_transfer/transfer/transfer_model.dart';
import 'package:blogapp/features/news/pages/news/transfer_news/top_transfer/transfer/transfer_state.dart';

class TransferBloc extends Bloc<TransferEvent, TransferState> {
  TransferBloc() : super(TransferState()) {
    on<TransferEvent>((event, emit) {});
    on<TransferRequested>(_handleTransferRequested);
    on<LoadNextTransferPage>(_handleLoadNextPage);
  }

  Future<void> _handleTransferRequested(
      TransferRequested event, Emitter<TransferState> emit) async {
    emit(state.copyWith(
      status: TransferStatus.loading,
      pageNumber: 1,
      isLastPage: false,
      isLoadingMore: false,
      transfers: const [],
      errorMessage: null,
    ));
    try {
      final url = BaseUrl().url;
      final response = await http
          .get(Uri.parse('$url/api/transfers?pageNumber=1'));
      if (response.statusCode == 200) {
        final parsedData = jsonDecode(response.body);
        final result = (parsedData['response'] ?? []) as List<dynamic>;
        final isLastPage = parsedData['isLastPage'] == true ||
            result.isEmpty;
        List<TransferModel> lists =
            result.map((item) => TransferModel.fromJson(item)).toList();

        emit(state.copyWith(
          status: TransferStatus.success,
          transfers: lists,
          pageNumber: 2,
          isLastPage: isLastPage,
        ));
      } else {
        emit(state.copyWith(status: TransferStatus.failure));
      }
    } catch (e) {
      emit(state.copyWith(
        status: TransferStatus.failure,
        errorMessage: e.toString(),
      ));
      print(e);
    }
  }

  Future<void> _handleLoadNextPage(
      LoadNextTransferPage event, Emitter<TransferState> emit) async {
    if (state.isLoadingMore || state.isLastPage) {
      return;
    }

    emit(state.copyWith(isLoadingMore: true));
    try {
      final url = BaseUrl().url;
      final currentPage = state.pageNumber;
      final response = await http
          .get(Uri.parse('$url/api/transfers?pageNumber=$currentPage'));
      if (response.statusCode == 200) {
        final parsedData = jsonDecode(response.body);
        final result = (parsedData['response'] ?? []) as List<dynamic>;
        final isLastPage = parsedData['isLastPage'] == true ||
            result.isEmpty;
        List<TransferModel> lists =
            result.map((item) => TransferModel.fromJson(item)).toList();
        emit(state.copyWith(
          isLoadingMore: false,
          status: TransferStatus.success,
          transfers: [...state.transfers, ...lists],
          pageNumber: currentPage + 1,
          isLastPage: isLastPage,
        ));
      } else {
        emit(state.copyWith(
          isLoadingMore: false,
          status: TransferStatus.failure,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        isLoadingMore: false,
        status: TransferStatus.failure,
        errorMessage: e.toString(),
      ));
      print(e);
    }
  }
}
