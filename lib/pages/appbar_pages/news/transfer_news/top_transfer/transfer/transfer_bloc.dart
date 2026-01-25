import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;

import '../../../../../../util/baseUrl.dart';
import 'transfer_event.dart';
import 'transfer_model.dart';
import 'transfer_state.dart';

class TransferBloc extends Bloc<TransferEvent, TransferState> {
  TransferBloc() : super(TransferState()) {
    on<TransferEvent>((event, emit) {});
    on<TransferRequested>(_handleTransferRequested);
    on<LoadNextTransferPage>(_handleLoadNextPage);
  }

  Future<void> _handleTransferRequested(
      TransferRequested event, Emitter<TransferState> emit) async {
    emit(state.copyWith(
        status: Transferstatus.requested,
        pageNumber: 1,
        loading: false,
        isLastPage: false));
    try {
      String url = BaseUrl().url;
      final response = await http
          .get(Uri.parse('$url/api/transfer?pageNumber=${state.pageNumber}'));

      if (response.statusCode == 200) {
        final parsedData = jsonDecode(response.body);
        final result = parsedData['response'] as List<dynamic>;

        List<TransferModel> lists =
            result.map((item) => TransferModel.fromJson(item)).toList();

        emit(state.copyWith(
            status: Transferstatus.requestSuccess,
            Transfer: lists,
            pageNumber: 2));
      } else {
        emit(state.copyWith(status: Transferstatus.requestFailed));
      }
    } catch (e) {
      emit(state.copyWith(status: Transferstatus.requestFailed));
      print(e);
    }
  }

  Future<void> _handleLoadNextPage(
      LoadNextTransferPage event, Emitter<TransferState> emit) async {
    if (state.loading || state.isLastPage) {
      return;
    }

    emit(state.copyWith(loading: true));
    try {
      String url = BaseUrl().url;

      final response = await http
          .get(Uri.parse('$url/api/transfer?pageNumber=${state.pageNumber}'));
      if (response.statusCode == 200) {
        final parsedData = jsonDecode(response.body);
        final result = parsedData['response'] as List<dynamic>;
        if (result.isEmpty) {
          emit(state.copyWith(isLastPage: true, loading: false));
          return;
        }
        List<TransferModel> lists =
            result.map((item) => TransferModel.fromJson(item)).toList();
        emit(state.copyWith(
            loading: false,
            status: Transferstatus.requestSuccess,
            Transfer: [...state.Transfer, ...lists],
            pageNumber: state.pageNumber + 1));
      } else {
        emit(state.copyWith(
            loading: false, status: Transferstatus.requestFailed));
      }
    } catch (e) {
      emit(state.copyWith(
        loading: false,
        status: Transferstatus.requestFailed,
      ));
      print(e);
    }
  }
}
