class AdminCategoryData {
  String? category;
  String? id;
  bool? active;

  AdminCategoryData({required this.active, required this.category, required this.id});

  AdminCategoryData.fromMap(Map<String, dynamic> map) {
    category = map['category'];
    id = map['id'];
    active = map['active'];
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'category': category, 'active': active};
  }
}
