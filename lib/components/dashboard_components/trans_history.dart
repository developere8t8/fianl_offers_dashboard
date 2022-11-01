// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fianl_offer_dashboard/constants.dart';
import 'package:fianl_offer_dashboard/models/lodge.dart';
import 'package:fianl_offer_dashboard/models/offers.dart';
import 'package:fianl_offer_dashboard/pages/edit_product.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';

import '../../widgets/error.dart';

class TransHistory extends StatefulWidget {
  const TransHistory({
    super.key,
  });

  @override
  State<TransHistory> createState() => _TransHistoryState();
}

class _TransHistoryState extends State<TransHistory> {
  bool isloading = false;
  List<LodgeData> lodges = [];

  @override
  void initState() {
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 25),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(11),
        child: Container(
          width: 620,
          height: 737,
          decoration: BoxDecoration(
            color: kColorWhite,
          ),
          child: isloading
              ? Center(
                  child: SizedBox(
                    width: 100,
                    height: 100,
                    child: LoadingIndicator(
                      indicatorType: Indicator.orbit,
                      colors: [Colors.red, Colors.blue],
                    ),
                  ),
                )
              : SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: DataTable(
                      dataRowHeight: 80.0,
                      horizontalMargin: 46,
                      headingTextStyle:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: kUIDark),
                      dataTextStyle: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                      headingRowColor: MaterialStateColor.resolveWith(
                        (states) {
                          return Color(0xFFF3F3F3);
                        },
                      ),
                      columns: <DataColumn>[
                        DataColumn(
                          label: Text('Product name'),
                        ),
                        DataColumn(
                          label: Text('Offers'),
                        ),
                        DataColumn(
                          label: Text('Status'),
                        ),
                        DataColumn(
                          label: Text(''),
                        ),
                      ],
                      rows: lodges
                          .map((e) => DataRow(cells: [
                                DataCell(Text(
                                  e.name!,
                                  style: TextStyle(
                                    color: kUIDark,
                                  ),
                                )),
                                DataCell(
                                  Wrap(
                                    children: [
                                      Image.asset(
                                        'assets/icons/Tag.png',
                                        scale: 5,
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Text(e.bookings!.toString())
                                    ],
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    e.adminStatus!,
                                    style: TextStyle(
                                        color: e.adminStatus == 'Accepted'
                                            ? kPrimary1
                                            : e.adminStatus == 'Pending'
                                                ? kColorOrange
                                                : e.adminStatus == 'Declined'
                                                    ? kPrimary2
                                                    : kUIDark),
                                  ),
                                ),
                                DataCell(
                                  IconButton(
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => EditProduct(lodgedata: e)));
                                    },
                                    icon: Image.asset('assets/icons/eye.png'),
                                  ),
                                ),
                              ]))
                          .toList()),
                ),
        ),
      ),
    );
  }

  //getting required data
  Future getData() async {
    try {
      final user = FirebaseAuth.instance.currentUser!;
      setState(() {
        isloading = true;
      });

      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('lodges')
          .where('companyid', isEqualTo: user.uid)
          .get();
      if (snapshot.docs.isNotEmpty) {
        lodges = snapshot.docs.map((e) => LodgeData.fromMap(e.data() as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ErrorDialog(
                  title: 'Error',
                  message: e.toString(),
                  type: 'E',
                  function: () {
                    Navigator.pop(context);
                  },
                  buttontxt: 'Close')));
    } finally {
      isloading = false;
      setState(() {});
    }
  }
}
