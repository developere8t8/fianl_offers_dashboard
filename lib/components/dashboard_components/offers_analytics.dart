// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fianl_offer_dashboard/models/offers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import '../../constants.dart';
import 'package:intl/intl.dart';

import '../../widgets/error.dart';

class OffersAnalytics extends StatefulWidget {
  const OffersAnalytics({
    super.key,
  });

  @override
  State<OffersAnalytics> createState() => _OffersAnalyticsState();
}

class _OffersAnalyticsState extends State<OffersAnalytics> {
  List<OffersData> allOffers = [];
  List<OffersData> acceptOffers = [];
  List<OffersData> rejectedOffers = [];
  List<OffersData> activeOffers = [];

  String selectedMonth = 'select date';
  bool datePicker = false;
  bool isLoading = false;
  DateTime startDate = DateTime.now().subtract(Duration(days: 30));
  DateTime endDate = DateTime.now();

  @override
  void initState() {
    getOffers();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Container(
            width: 360,
            height: 354,
            decoration: BoxDecoration(
              color: kColorWhite,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Center(
              child: SizedBox(
                height: 50,
                width: 50,
                child: LoadingIndicator(
                  indicatorType: Indicator.orbit,
                ),
              ),
            ))
        : Column(
            children: [
              Container(
                width: 360,
                height: 354,
                decoration: BoxDecoration(
                  color: kColorWhite,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 5,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Offers Analytics',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: kUIDark,
                            ),
                          ),
                          Container(
                              width: 160,
                              height: 30,
                              decoration: BoxDecoration(
                                  color: kUILight3, borderRadius: BorderRadius.circular(15)),
                              child: Row(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(left: 3),
                                    child: Icon(Icons.date_range),
                                  ),
                                  SizedBox(
                                    width: 100,
                                    child: Text(selectedMonth),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        datePicker = true;
                                      });
                                    },
                                    child: Icon(Icons.arrow_drop_down),
                                  )
                                ],
                              ))
                        ],
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      datePicker
                          ? Column(
                              children: [
                                SizedBox(
                                  width: 320,
                                  height: 230,
                                  child: SfDateRangePicker(
                                    selectionMode: DateRangePickerSelectionMode.range,
                                    view: DateRangePickerView.month,
                                    onSelectionChanged: (args) => {
                                      if (args.value is PickerDateRange)
                                        {
                                          setState(() {
                                            startDate = args.value.startDate ?? DateTime.now();
                                            endDate = args.value.endDate ?? DateTime.now();
                                          })
                                        }
                                    },
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Padding(
                                  padding: EdgeInsets.only(left: 30),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          setState(() {
                                            datePicker = false;
                                          });
                                        },
                                        child: Text(
                                          'Cancel',
                                          style: TextStyle(color: Colors.blue),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          setState(() {
                                            datePicker = false;
                                          });
                                          getOffersDates(startDate, endDate);
                                        },
                                        child: Text('Ok', style: TextStyle(color: Colors.blue)),
                                      )
                                    ],
                                  ),
                                )
                              ],
                            )
                          : SizedBox(
                              width: 250,
                              height: 250,
                              child: Column(
                                children: [
                                  Text(
                                      '${DateFormat('MMM dd yyyy').format(startDate)} - ${DateFormat('MMM dd yyyy').format(endDate)}'),
                                  Expanded(
                                    child: PieChart(
                                      PieChartData(
                                        startDegreeOffset:
                                            allOffers.isEmpty ? 0 : allOffers.length.toDouble(),
                                        sectionsSpace: 0,
                                        sections: [
                                          PieChartSectionData(
                                            color: kPrimary1,
                                            value: acceptOffers.isEmpty
                                                ? 0
                                                : acceptOffers.length.toDouble(),
                                            showTitle: false,
                                          ),
                                          PieChartSectionData(
                                            color: kColorYellow,
                                            value: rejectedOffers.isEmpty
                                                ? 0
                                                : rejectedOffers.length.toDouble(),
                                            showTitle: false,
                                          ),
                                          PieChartSectionData(
                                            color: kPrimary2,
                                            value: activeOffers.isEmpty
                                                ? 0
                                                : activeOffers.length.toDouble(),
                                            showTitle: false,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Row(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: 5,
                                            height: 5,
                                            decoration: BoxDecoration(
                                                shape: BoxShape.circle, color: kColorYellow),
                                          ),
                                          const SizedBox(
                                            width: 7,
                                          ),
                                          SizedBox(
                                            width: 120,
                                            child: Text('Received  ${allOffers.length}'),
                                          ),
                                          const SizedBox(
                                            width: 7,
                                          ),
                                          Container(
                                            width: 5,
                                            height: 5,
                                            decoration:
                                                BoxDecoration(shape: BoxShape.circle, color: kColorBlue),
                                          ),
                                          const SizedBox(
                                            width: 7,
                                          ),
                                          Text('Accepted  ${acceptOffers.length}'),
                                        ],
                                      )
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: 5,
                                            height: 5,
                                            decoration: BoxDecoration(
                                                shape: BoxShape.circle, color: kColorOrange),
                                          ),
                                          const SizedBox(
                                            width: 7,
                                          ),
                                          SizedBox(
                                            width: 120,
                                            child: Text('Rejected  ${rejectedOffers.length}'),
                                          ),
                                          const SizedBox(
                                            width: 7,
                                          ),
                                          Container(
                                            width: 5,
                                            height: 5,
                                            decoration:
                                                BoxDecoration(shape: BoxShape.circle, color: kPrimary2),
                                          ),
                                          const SizedBox(
                                            width: 7,
                                          ),
                                          Text('Active  ${activeOffers.length}'),
                                          const SizedBox(
                                            width: 7,
                                          ),
                                        ],
                                      )
                                    ],
                                  )
                                ],
                              )),
                    ],
                  ),
                ),
              ),
              // SizedBox(
              //   height: 26,
              // ),
              // Container(
              //   width: 360,
              //   height: 354,
              //   decoration: BoxDecoration(
              //     color: kColorWhite,
              //     borderRadius: BorderRadius.circular(18),
              //   ),
              //   child: Padding(
              //     padding: const EdgeInsets.symmetric(horizontal: 27),
              //     child: Column(
              //       children: [
              //         SizedBox(
              //           height: 13.5,
              //         ),
              //         Row(
              //           children: [
              //             Text(
              //               'Income Analytics',
              //               style: TextStyle(
              //                 fontSize: 20,
              //                 fontWeight: FontWeight.w600,
              //                 color: kUIDark,
              //               ),
              //             ),
              //           ],
              //         ),
              //         SizedBox(
              //           height: 30,
              //         ),
              //         SizedBox(
              //           width: 182,
              //           height: 182,
              //           child: PieChart(
              //             PieChartData(
              //               startDegreeOffset: 130,
              //               sectionsSpace: 0,
              //               sections: [
              //                 PieChartSectionData(
              //                   color: kPrimary1,
              //                   value: 10,
              //                   showTitle: false,
              //                 ),
              //                 PieChartSectionData(
              //                   color: kColorYellow,
              //                   value: 10,
              //                   showTitle: false,
              //                 ),
              //                 PieChartSectionData(
              //                   color: kPrimary2,
              //                   value: 10,
              //                   showTitle: false,
              //                 ),
              //                 PieChartSectionData(
              //                   color: kColorOrange,
              //                   value: 4,
              //                   showTitle: false,
              //                 ),
              //               ],
              //             ),
              //           ),
              //         ),
              //       ],
              //     ),
              //   ),
              // ),
            ],
          );
  }

  //getting data for offer analysis

  Future getOffers() async {
    try {
      setState(() {
        isLoading = true;
      });
      final company = FirebaseAuth.instance.currentUser!;

      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('offers')
          .where('compnyId', isEqualTo: company.uid)
          .where('date', isGreaterThan: startDate)
          .get();

      if (snapshot.docs.isNotEmpty) {
        setState(() {
          allOffers =
              snapshot.docs.map((e) => OffersData.fromMap(e.data() as Map<String, dynamic>)).toList();
          acceptOffers = allOffers.where((element) => element.status == 'accepted').toList();
          rejectedOffers = allOffers.where((element) => element.status == 'rejected').toList();
          activeOffers = allOffers.where((element) => element.status == 'pending').toList();
        });
      }
      setState(() {
        isLoading = false;
      });
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
      setState(() {
        isLoading = false;
      });
    }
  }

  //getting data for offer analysis between dates

  Future getOffersDates(DateTime strtDate, DateTime end) async {
    try {
      setState(() {
        isLoading = true;
      });
      final company = FirebaseAuth.instance.currentUser!;

      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('offers')
          .where('compnyId', isEqualTo: company.uid)
          .where('date', isGreaterThan: strtDate)
          .get();

      if (snapshot.docs.isNotEmpty) {
        setState(() {
          allOffers =
              snapshot.docs.map((e) => OffersData.fromMap(e.data() as Map<String, dynamic>)).toList();
          allOffers = allOffers.where((element) => element.date!.toDate().isBefore(end)).toList();

          acceptOffers = allOffers.where((element) => element.status == 'accepted').toList();
          rejectedOffers = allOffers.where((element) => element.status == 'rejected').toList();
          activeOffers = allOffers.where((element) => element.status == 'pending').toList();
        });
      }
      setState(() {
        isLoading = false;
      });
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
      setState(() {
        isLoading = false;
      });
    }
  }
}
