abstract class TransferEvent {}

class TransferRequested extends TransferEvent {
  TransferRequested();
}

class CompletedRequested extends TransferEvent {
  CompletedRequested();
}

class HeresayRequested extends TransferEvent {
  HeresayRequested();
}

class LoadNextTransferPage extends TransferEvent {}
