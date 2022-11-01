import 'package:cloud_firestore/cloud_firestore.dart';

class CompanyData {
  String? id;
  String? name;
  String? email;
  String? contact;
  String? reg;
  Timestamp? date;
  bool? active;
  String? imgUrl;
  String? companyName;
  String? region;
  String? physicalAddress;
  String? address;
  String? city;
  String? vat;
  String? admin;
  String? fb;
  String? insta;
  String? web;
  String? adminStatus;

  CompanyData(
      {required this.active,
      required this.contact,
      required this.date,
      required this.email,
      required this.id,
      required this.name,
      required this.reg,
      required this.imgUrl,
      required this.companyName,
      required this.address,
      required this.physicalAddress,
      required this.region,
      required this.city,
      required this.vat,
      required this.admin,
      required this.fb,
      required this.insta,
      required this.web,
      required this.adminStatus});

  CompanyData.fromMap(Map<String, dynamic> map) {
    active = map['active'];
    contact = map['contact'];
    date = map['date'];
    email = map['email'];
    id = map['id'];
    name = map['name'];
    reg = map['reg'];
    imgUrl = map['imgurl'];
    companyName = map['company'];
    address = map['address'];
    physicalAddress = map['physicalAddress'];
    region = map['region'];
    city = map['city'];
    vat = map['vat'];
    admin = map['admin'];
    fb = map['fb'];
    insta = map['insta'];
    web = map['web'];
    adminStatus = map['adminStatus'];
  }

  Map<String, dynamic> toMap() {
    return {
      'active': active,
      'contact': contact,
      'date': date,
      'email': email,
      'id': id,
      'name': name,
      'reg': reg,
      'imgurl': imgUrl,
      'company': companyName,
      'address': address,
      'physicalAddress': physicalAddress,
      'region': region,
      'city': city,
      'vat': vat,
      'admin': admin,
      'fb': fb,
      'web': web,
      'insta': insta,
      'adminStatus': adminStatus
    };
  }
}
