double getProportion(int vote, int totalCount) {
  if (totalCount == 0) {
    return 0.0;
  }
  final proportion = vote / totalCount;
  return proportion.toDouble();
}
