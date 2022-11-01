// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fianl_offer_dashboard/constants.dart';
import 'package:fianl_offer_dashboard/models/bardata.dart';
import 'package:fianl_offer_dashboard/models/data.dart';
import 'package:fianl_offer_dashboard/models/lodge.dart';
import 'package:fianl_offer_dashboard/models/offers.dart';
import 'package:fianl_offer_dashboard/pages/offers_data.dart';
import 'package:fianl_offer_dashboard/widgets/bar_chart.dart';
import 'package:fianl_offer_dashboard/widgets/side_bar.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:intl/intl.dart';
import 'package:darq/darq.dart';

class InfoCardOffers extends StatefulWidget {
  final int totlaOffers;
  final int pendingOffers;
  final List<OffersData> newoffers;

  const InfoCardOffers(
      {Key? key, required this.pendingOffers, required this.totlaOffers, required this.newoffers})
      : super(key: key);

  @override
  State<InfoCardOffers> createState() => _InfoCardOffersState();
}

class _InfoCardOffersState extends State<InfoCardOffers> {
  List distinctDate = []; //for distinct dates
  List? day1;
  List? day2;
  List? day3;
  List? day4;
  List? day5;
  List? day6;
  List? day7;
  List<Data>? listData = [];

  BarData? data;
  @override
  void initState() {
    super.initState();
    getDateRange();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 400,
        height: 154,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: kColorAqua,
          boxShadow: [
            BoxShadow(
              color: kBoxShadowColor,
              offset: Offset(19, 19),
              blurRadius: 47,
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              top: 15,
              left: 20,
              child: Text(
                'Offers',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: kUIDark,
                ),
              ),
            ),
            Positioned(
              top: 15,
              right: 70,
              child: IconButton(
                onPressed: () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SideBar(
                                page: 1,
                              )));
                },
                icon: Image.asset('assets/icons/eye.png'),
              ),
            ),
            Positioned(
              top: 15,
              right: 30,
              child: IconButton(
                onPressed: () {},
                icon: Image.asset('assets/icons/copy.png'),
              ),
            ),
            Positioned(
              left: 20,
              bottom: 30,
              child: Text(
                widget.pendingOffers.toString(),
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w600,
                  color: kPrimary1,
                ),
              ),
            ),
            Positioned(
              left: 20,
              bottom: 10,
              child: Text(
                'Pending',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: kUILight2,
                ),
              ),
            ),
            Positioned(
              left: 90,
              bottom: 30,
              child: Text(
                widget.totlaOffers.toString(),
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w600,
                  color: kPrimary1,
                ),
              ),
            ),
            Positioned(
              left: 90,
              bottom: 10,
              child: Text(
                'Created',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: kUILight2,
                ),
              ),
            ),
            Positioned(
                left: 160,
                bottom: 10,
                child: SizedBox(
                  height: 90,
                  width: 240,
                  child: BarChartWidget(
                    data: listData!,
                  ),
                ))
          ],
        ));
  }

  //getting range of date

  getDateRange() {
    try {
      DateTime startDate = DateTime.now().subtract(Duration(days: 7));
      for (int i = 0; i < 7; i++) {
        setState(() {
          distinctDate.add(DateFormat('yyyy-MM-dd').format(startDate.add(Duration(days: i - 1))));
        });
      }
      setState(() {
        day1 = widget.newoffers.where((element) => element.dateCreated! == distinctDate[0]).toList();
        day2 = widget.newoffers.where((element) => element.dateCreated! == distinctDate[1]).toList();
        day3 = widget.newoffers.where((element) => element.dateCreated! == distinctDate[2]).toList();
        day4 = widget.newoffers.where((element) => element.dateCreated! == distinctDate[3]).toList();
        day5 = widget.newoffers.where((element) => element.dateCreated! == distinctDate[4]).toList();
        day6 = widget.newoffers.where((element) => element.dateCreated! == distinctDate[5]).toList();
        day7 = widget.newoffers.where((element) => element.dateCreated! == distinctDate[6]).toList();
      });
      setState(() {
        listData!.add(Data(
            id: 0,
            name: DateFormat('EEE').format(DateTime.parse(distinctDate[0])),
            y: day1!.isEmpty ? 0 : day1!.length));
        listData!.add(Data(
            id: 1,
            name: DateFormat('EEE').format(DateTime.parse(distinctDate[1])),
            y: day2!.isEmpty ? 0 : day2!.length));
        listData!.add(Data(
            id: 2,
            name: DateFormat('EEE').format(DateTime.parse(distinctDate[2])),
            y: day3!.isEmpty ? 0 : day3!.length));
        listData!.add(Data(
            id: 3,
            name: DateFormat('EEE').format(DateTime.parse(distinctDate[3])),
            y: day4!.isEmpty ? 0 : day4!.length));
        listData!.add(Data(
            id: 4,
            name: DateFormat('EEE').format(DateTime.parse(distinctDate[4])),
            y: day5!.isEmpty ? 0 : day5!.length));
        listData!.add(Data(
            id: 5,
            name: DateFormat('EEE').format(DateTime.parse(distinctDate[5])),
            y: day6!.isEmpty ? 0 : day6!.length));
        listData!.add(Data(
            id: 6,
            name: DateFormat('EEE').format(DateTime.parse(distinctDate[6])),
            y: day7!.isEmpty ? 0 : day7!.length));
      });
      // print('distinct');
      // print(data!.data!.length);
      // // for (var k in listData!) {
      // //   print(k.id);
      // //   print(k.name);
      // //   print(k.y);
      // //   print('againg');
      // // }
    } catch (e) {
      print(e.toString());
    }
  }
}
