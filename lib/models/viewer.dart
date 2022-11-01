import 'package:cloud_firestore/cloud_firestore.dart';

class OfferViewerData {
  String? companyid;
  double? amount;
  String? deadLine;
  Timestamp? from;
  String? id;
  String? lodgeid;
  int? persons;
  String? status;
  Timestamp? to;
  String? userid;
  String? dateCreated;
  Timestamp? date;
  double? actualAmount;
  String? paid;
  String? lodgeName;
  bool? selected;
  bool? accepted;
  int? waiting;

  OfferViewerData({
    required this.amount,
    required this.companyid,
    required this.deadLine,
    required this.from,
    required this.id,
    required this.lodgeid,
    required this.persons,
    required this.status,
    required this.to,
    required this.userid,
    required this.dateCreated,
    required this.date,
    required this.actualAmount,
    required this.paid,
    required this.lodgeName,
    required this.selected,
    required this.accepted,
    required this.waiting,
  });
}
