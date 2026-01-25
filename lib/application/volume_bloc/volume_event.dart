abstract class VolumeEvent {}

class VolumeChangeRequested extends VolumeEvent {
  double volume;
  VolumeChangeRequested({required this.volume});
}
