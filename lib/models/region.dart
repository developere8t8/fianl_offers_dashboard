class RegionData {
  String? id;
  bool? active;
  String? region;

  RegionData({required this.active, required this.id, required this.region});

  RegionData.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    active = map['active'];
    region = map['region'];
  }

  Map<String, dynamic> tomap() {
    return {'id': id, 'active': active, 'region': region};
  }
}
