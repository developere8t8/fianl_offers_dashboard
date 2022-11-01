class CategoryData {
  String? id;
  List? category;
  String? companyid;

  CategoryData({required this.category, required this.companyid, required this.id});

  CategoryData.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    category = map['category'];
    companyid = map['companyid'];
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'category': category, 'companyid': companyid};
  }
}
