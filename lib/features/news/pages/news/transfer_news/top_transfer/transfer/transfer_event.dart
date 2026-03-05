abstract class TransferEvent {}

class TransferRequested extends TransferEvent {
  TransferRequested();
}

class LoadNextTransferPage extends TransferEvent {}
