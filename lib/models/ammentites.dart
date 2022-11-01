class AmentitesData {
  String? item;
  bool? present;

  AmentitesData({
    required this.item,
    required this.present,
  });

  Map<String, dynamic> toMap() {
    return {'item': item, 'present': present};
  }
}
