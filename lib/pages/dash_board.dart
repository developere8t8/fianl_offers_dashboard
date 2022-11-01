// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fianl_offer_dashboard/components/dashboard_components/incom_analysis.dart';
import 'package:fianl_offer_dashboard/components/dashboard_components/info_card_offers.dart';
import 'package:fianl_offer_dashboard/constants.dart';
import 'package:fianl_offer_dashboard/models/company.dart';
import 'package:fianl_offer_dashboard/models/lodge.dart';
import 'package:fianl_offer_dashboard/models/offers.dart';
import 'package:fianl_offer_dashboard/pages/Auth.dart';
import 'package:fianl_offer_dashboard/widgets/error.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../components/dashboard_components/info_card.dart';
import '../components/dashboard_components/offers_analytics.dart';
import '../components/dashboard_components/trans_history.dart';
import 'package:loading_indicator/loading_indicator.dart';

class MyDashboard extends StatefulWidget {
  const MyDashboard({Key? key}) : super(key: key);

  @override
  State<MyDashboard> createState() => _MyDashboardState();
}

class _MyDashboardState extends State<MyDashboard> {
  final user = FirebaseAuth.instance.currentUser!;
  bool isLoading = false;
  CompanyData? data;
  List<LodgeData> lodgeData = [];
  List<LodgeData> activelodge = [];
  List<LodgeData> newlodge = []; //for graph
  List<OffersData> alloffers = [];
  List<OffersData> pendingoffers = [];
  List<OffersData> newOffers = [];

  @override
  void initState() {
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: kDashboardBodyColor,
        appBar: AppBar(
          backgroundColor: kColorWhite,
          elevation: 0,
          title: const Text(
            'Dashboard',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 22,
              color: kColorBlue,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 40.5),
              child: Row(
                children: [
                  Text(
                    isLoading ? '' : data!.companyName!,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: kColorBlack),
                  ),
                  SizedBox(
                    width: 12,
                  ),
                  isLoading
                      ? CircleAvatar()
                      : data!.imgUrl!.isEmpty
                          ? CircleAvatar()
                          : CircleAvatar(
                              backgroundImage: NetworkImage(data!.imgUrl!),
                            ),
                ],
              ),
            ),
          ],
        ),
        body: isLoading
            ? Center(
                child: SizedBox(
                  width: 200,
                  height: 50,
                  child: Row(
                    children: [
                      LoadingIndicator(indicatorType: Indicator.lineScalePulseOut),
                      LoadingIndicator(indicatorType: Indicator.lineScalePulseOut)
                    ],
                  ),
                ),
              )
            : Row(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 1,
                    width: MediaQuery.of(context).size.width / 1.148,
                    child: ListView(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 43,
                            ),
                            Row(
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(left: 30),
                                  child: InfoCard(
                                      activeproducts: activelodge.isEmpty ? 0 : activelodge.length,
                                      totalproducts: lodgeData.isEmpty ? 0 : lodgeData.length,
                                      newlodgeData: newlodge),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(left: 30),
                                  child: InfoCardOffers(
                                      pendingOffers: pendingoffers.isEmpty ? 0 : pendingoffers.length,
                                      totlaOffers: alloffers.isEmpty ? 0 : alloffers.length,
                                      newoffers: newOffers),
                                ),
                              ],
                            ),
                            SizedBox(height: 30),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TransHistory(),
                                SizedBox(
                                  width: 32,
                                ),
                                Column(
                                  children: [
                                    OffersAnalytics(),
                                    IncomeAnalytics(),
                                  ],
                                )
                              ],
                            ),
                            SizedBox(
                              height: 30,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  //getting analytic data
  Future getData() async {
    try {
      setState(() {
        isLoading = true;
      });
      //getting  company info
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('compnies').where('id', isEqualTo: user.uid).get();
      if (snapshot.docs.isNotEmpty) {
        setState(() {
          data = CompanyData.fromMap(snapshot.docs.first.data() as Map<String, dynamic>);
        });
      }
      QuerySnapshot snapProduct = await FirebaseFirestore.instance
          .collection('lodges')
          .where('companyid', isEqualTo: data!.id!)
          .get();
      setState(() {
        lodgeData =
            snapProduct.docs.map((e) => LodgeData.fromMap(e.data() as Map<String, dynamic>)).toList();
        activelodge = lodgeData.where((element) => element.status == 'active').toList();
        newlodge = lodgeData
            .where((element) =>
                DateTime.parse(element.dateCreated!).isAfter(DateTime.now().subtract(Duration(days: 7))))
            .toList();
      });

      QuerySnapshot snapoffer = await FirebaseFirestore.instance
          .collection('offers')
          .where('compnyId', isEqualTo: data!.id!)
          .get();
      setState(() {
        alloffers =
            snapoffer.docs.map((e) => OffersData.fromMap(e.data() as Map<String, dynamic>)).toList();
        pendingoffers = alloffers.where((element) => element.status == 'pending').toList();
        newOffers = alloffers
            .where((element) =>
                DateTime.parse(element.dateCreated!).isAfter(DateTime.now().subtract(Duration(days: 7))))
            .toList();
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
