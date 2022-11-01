// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fianl_offer_dashboard/constants.dart';
import 'package:fianl_offer_dashboard/models/company.dart';
import 'package:fianl_offer_dashboard/models/lodge.dart';
import 'package:fianl_offer_dashboard/pages/edit_product.dart';
import 'package:fianl_offer_dashboard/widgets/button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:html' as webFile;
import '../widgets/error.dart';
import '../widgets/side_bar.dart';

class MyProducts extends StatefulWidget {
  const MyProducts({Key? key}) : super(key: key);

  @override
  State<MyProducts> createState() => _MyProductsState();
}

class _MyProductsState extends State<MyProducts> {
  TextEditingController search = TextEditingController();
  final user = FirebaseAuth.instance.currentUser!;
  bool isLoading = false;
  CompanyData? data;
  List<String> lodgeNames = [];
  List<LodgeData> temp = [];
  List<LodgeData> lodgeData = [];
  List<LodgeData> acceptedLodges = [];
  List<LodgeData> rejectedLodges = [];
  List<LodgeData> pendingLodges = [];
  List<LodgeData> inactiveLodges = [];
  List<LodgeData> liveLodges = [];
  List<LodgeData> archiveLodges = [];

  @override
  void initState() {
    getallData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 7,
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: kColorWhite,
            elevation: 0,
            title: const Text(
              'My Products',
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
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 24),
                  Row(
                    children: [
                      SizedBox(
                        width: 340,
                        height: 47,
                        child: TypeAheadFormField(
                          suggestionsCallback: (patteren) => lodgeNames.where(
                              (element) => element.toLowerCase().contains(patteren.toLowerCase())),
                          onSuggestionSelected: (String value) {
                            search.text = value;
                            getAllDatabyName(value);
                          },

                          itemBuilder: (_, String item) => Card(
                            color: Colors.white,
                            child: ListTile(
                              title: Text(item),
                            ),
                          ),
                          getImmediateSuggestions: true,
                          //hideSuggestionsOnKeyboardHide: true,
                          hideOnEmpty: false,
                          noItemsFoundBuilder: (_) => const Padding(
                            padding: EdgeInsets.all(5.0),
                            child: Text('No date found'),
                          ),
                          textFieldConfiguration: TextFieldConfiguration(
                              decoration: InputDecoration(
                                prefixIcon: Icon(
                                  CupertinoIcons.search,
                                  size: 17,
                                ),
                                // suffixIcon: Icon(
                                //   CupertinoIcons.mic_fill,
                                //   size: 17,
                                // ),
                                hintText: 'Search',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(128),
                                  borderSide: BorderSide(color: kUILight, width: 1),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(128),
                                  borderSide: BorderSide(color: kUILight, width: 1),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                hintStyle: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: kUILight2,
                                ),
                              ),
                              controller: search,
                              onChanged: ((value) {
                                if (value == '') {
                                  getAllDatabyAll();
                                }
                              })),
                        ),
                      ),
                      SizedBox(width: 24),
                      SizedBox(
                        width: 339,
                        height: 52,
                        child: FixedPrimary(
                            buttonText: 'Create New Product',
                            ontap: () {
                              Navigator.pushReplacement(
                                  context, MaterialPageRoute(builder: (context) => SideBar(page: 3)));
                            }),
                      ),
                    ],
                  ),
                  SizedBox(height: 29),
                  TabBar(
                    isScrollable: true,
                    labelPadding: EdgeInsets.symmetric(horizontal: 20),
                    indicatorPadding: EdgeInsets.zero,
                    indicatorColor: kPrimary2,
                    indicatorSize: TabBarIndicatorSize.label,
                    labelColor: kPrimary2,
                    unselectedLabelColor: kUILight2,
                    labelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    unselectedLabelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                    indicatorWeight: 3,
                    tabs: [
                      Tab(text: 'All'),
                      Tab(text: 'Accepted'),
                      Tab(text: 'Declined'),
                      Tab(text: 'Pending'),
                      Tab(text: 'Inactive'),
                      Tab(text: 'Live'),
                      Tab(text: 'Archived'),
                    ],
                  ),
                  Divider(
                    height: 1,
                    color: kTabBarLine,
                  ),
                  SizedBox(height: 24),
                  SizedBox(
                    width: 1170,
                    height: 621,
                    child: TabBarView(
                      children: [
                        //all lodges
                        isLoading
                            ? Center(
                                child: SizedBox(
                                  width: 150,
                                  height: 150,
                                  child: LoadingIndicator(
                                    indicatorType: Indicator.orbit,
                                    colors: [Colors.red, Colors.blue],
                                  ),
                                ),
                              )
                            : InteractiveViewer(
                                scaleEnabled: false,
                                constrained: false,
                                child: DataTable(
                                    dataRowHeight: 80.0,
                                    //horizontalMargin: 46,
                                    headingTextStyle: TextStyle(
                                        fontSize: 14, fontWeight: FontWeight.w600, color: kUIDark),
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
                                        label: Text(''),
                                      ),
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
                                        label: Text('Set Inactive/\nActive'),
                                      ),
                                      DataColumn(
                                        label: Text(''),
                                      ),
                                      DataColumn(
                                        label: Text(''),
                                      ),
                                      DataColumn(
                                        label: Text(''),
                                      ),
                                      DataColumn(
                                        label: Text(''),
                                      ),
                                    ],
                                    rows: lodgeData
                                        .map((e) => DataRow(cells: [
                                              DataCell(
                                                Row(
                                                  children: [
                                                    InkWell(
                                                      onTap: () {
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder: (context) => EditProduct(
                                                                      lodgedata: e,
                                                                      edit: true,
                                                                    )));
                                                      },
                                                      child: Image.asset(
                                                        'assets/icons/pencil.png',
                                                        scale: 4,
                                                      ),
                                                    ),
                                                    SizedBox(width: 11.5),
                                                    Text(
                                                      'Edit',
                                                      style: TextStyle(color: kUILight2),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              DataCell(
                                                Text(
                                                  e.name!,
                                                  style: TextStyle(
                                                    color: kUIDark,
                                                  ),
                                                ),
                                              ),
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
                                                Transform.scale(
                                                  scale: 0.8,
                                                  child: CupertinoSwitch(
                                                      value: e.status == 'active' ? true : false,
                                                      onChanged: (value) async {
                                                        setState(() {
                                                          if (value) {
                                                            e.status = 'active';
                                                          } else {
                                                            e.status = 'pending';
                                                          }
                                                        });
                                                        await FirebaseFirestore.instance
                                                            .collection('lodges')
                                                            .doc(e.id)
                                                            .update({'status': e.status});
                                                        getallData();
                                                      }),
                                                ),
                                              ),
                                              DataCell(
                                                Column(
                                                  children: [
                                                    SizedBox(height: 20),
                                                    InkWell(
                                                      onTap: () {
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder: (context) =>
                                                                    EditProduct(lodgedata: e)));
                                                      },
                                                      child: Image.asset(
                                                        'assets/icons/eye.png',
                                                        scale: 4,
                                                      ),
                                                    ),
                                                    SizedBox(height: 5),
                                                    Text(
                                                      'View',
                                                      style: TextStyle(
                                                          fontSize: 13,
                                                          fontWeight: FontWeight.w500,
                                                          color: kPrimary1),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              DataCell(
                                                Column(
                                                  children: [
                                                    SizedBox(height: 20),
                                                    InkWell(
                                                      onTap: () {
                                                        //TODO what we need to share
                                                        Share.share('What we are going to share');
                                                      },
                                                      child: Image.asset(
                                                        'assets/icons/share.png',
                                                        scale: 4,
                                                      ),
                                                    ),
                                                    SizedBox(height: 5),
                                                    Text(
                                                      'Share',
                                                      style: TextStyle(
                                                          fontSize: 13,
                                                          fontWeight: FontWeight.w500,
                                                          color: kPrimary1),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              DataCell(
                                                Column(
                                                  children: [
                                                    SizedBox(height: 20),
                                                    InkWell(
                                                      onTap: () async {
                                                        if (kIsWeb) {
                                                          var blob = webFile.Blob([
                                                            '''Name: ${e.name}
                                                              Category: ${e.category}
                                                               Description: ${e.description}
                                                               Latitude: ${e.latitude}
                                                               Longitude: ${e.longitude}
                                                               Photos Urls: ${e.photos}
                                                               Price: ${e.price}
                                                               Region: ${e.region}
                                                               Terms: ${e.terms}
                                                               Video Url: ${e.videoUrl}
                                                              '''
                                                          ], 'text/plan', 'native');
                                                          webFile.AnchorElement(
                                                            href:
                                                                webFile.Url.createObjectUrlFromBlob(blob)
                                                                    .toString(),
                                                          )
                                                            ..setAttribute("download", "${e.name}.txt")
                                                            ..click();
                                                        }
                                                        await FirebaseFirestore.instance
                                                            .collection('lodges')
                                                            .doc(e.id)
                                                            .update({'archive': true});
                                                        getallData();
                                                      },
                                                      child: Image.asset(
                                                        'assets/icons/archive.png',
                                                        scale: 4,
                                                      ),
                                                    ),
                                                    SizedBox(height: 5),
                                                    Text(
                                                      'Archive',
                                                      style: TextStyle(
                                                          fontSize: 13,
                                                          fontWeight: FontWeight.w500,
                                                          color: kPrimary1),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              DataCell(
                                                Column(
                                                  children: [
                                                    SizedBox(height: 20),
                                                    InkWell(
                                                      onTap: () {
                                                        //TODO add dulicate lodge in firebase
                                                      },
                                                      child: Image.asset(
                                                        'assets/icons/copy.png',
                                                        scale: 4,
                                                      ),
                                                    ),
                                                    SizedBox(height: 5),
                                                    Text(
                                                      'Duplicate',
                                                      style: TextStyle(
                                                          fontSize: 13,
                                                          fontWeight: FontWeight.w500,
                                                          color: kPrimary1),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ]))
                                        .toList()),
                              ),
                        //accepted lodges
                        isLoading
                            ? Center(
                                child: SizedBox(
                                  width: 150,
                                  height: 150,
                                  child: LoadingIndicator(
                                    indicatorType: Indicator.orbit,
                                    colors: [Colors.red, Colors.blue],
                                  ),
                                ),
                              )
                            : InteractiveViewer(
                                scaleEnabled: false,
                                constrained: false,
                                child: DataTable(
                                    dataRowHeight: 80.0,
                                    //horizontalMargin: 46,
                                    headingTextStyle: TextStyle(
                                        fontSize: 14, fontWeight: FontWeight.w600, color: kUIDark),
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
                                        label: Text(''),
                                      ),
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
                                        label: Text('Set Inactive/\nActive'),
                                      ),
                                      DataColumn(
                                        label: Text(''),
                                      ),
                                      DataColumn(
                                        label: Text(''),
                                      ),
                                      DataColumn(
                                        label: Text(''),
                                      ),
                                      DataColumn(
                                        label: Text(''),
                                      ),
                                    ],
                                    rows: acceptedLodges
                                        .map((e) => DataRow(cells: [
                                              DataCell(
                                                Row(
                                                  children: [
                                                    InkWell(
                                                      onTap: () {
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder: (context) => EditProduct(
                                                                      lodgedata: e,
                                                                      edit: true,
                                                                    )));
                                                      },
                                                      child: Image.asset(
                                                        'assets/icons/pencil.png',
                                                        scale: 4,
                                                      ),
                                                    ),
                                                    SizedBox(width: 11.5),
                                                    Text(
                                                      'Edit',
                                                      style: TextStyle(color: kUILight2),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              DataCell(
                                                Text(
                                                  e.name!,
                                                  style: TextStyle(
                                                    color: kUIDark,
                                                  ),
                                                ),
                                              ),
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
                                                Transform.scale(
                                                  scale: 0.8,
                                                  child: CupertinoSwitch(
                                                      value: e.status == 'active' ? true : false,
                                                      onChanged: (value) async {
                                                        setState(() {
                                                          if (value) {
                                                            e.status = 'active';
                                                          } else {
                                                            e.status = 'pending';
                                                          }
                                                        });
                                                        await FirebaseFirestore.instance
                                                            .collection('lodges')
                                                            .doc(e.id)
                                                            .update({'status': e.status});
                                                        getallData();
                                                      }),
                                                ),
                                              ),
                                              DataCell(
                                                Column(
                                                  children: [
                                                    SizedBox(height: 20),
                                                    InkWell(
                                                      onTap: () {
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder: (context) => EditProduct(
                                                                      lodgedata: e,
                                                                    )));
                                                      },
                                                      child: Image.asset(
                                                        'assets/icons/eye.png',
                                                        scale: 4,
                                                      ),
                                                    ),
                                                    SizedBox(height: 5),
                                                    Text(
                                                      'View',
                                                      style: TextStyle(
                                                          fontSize: 13,
                                                          fontWeight: FontWeight.w500,
                                                          color: kPrimary1),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              DataCell(
                                                Column(
                                                  children: [
                                                    SizedBox(height: 20),
                                                    InkWell(
                                                      onTap: () {
                                                        //TODO what we need to share
                                                        Share.share('What we are going to share');
                                                      },
                                                      child: Image.asset(
                                                        'assets/icons/share.png',
                                                        scale: 4,
                                                      ),
                                                    ),
                                                    SizedBox(height: 5),
                                                    Text(
                                                      'Share',
                                                      style: TextStyle(
                                                          fontSize: 13,
                                                          fontWeight: FontWeight.w500,
                                                          color: kPrimary1),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              DataCell(
                                                Column(
                                                  children: [
                                                    SizedBox(height: 20),
                                                    InkWell(
                                                      onTap: () async {
                                                        if (kIsWeb) {
                                                          var blob = webFile.Blob([
                                                            '''Name: ${e.name}
                                                              Category: ${e.category}
                                                               Description: ${e.description}
                                                               Latitude: ${e.latitude}
                                                               Longitude: ${e.longitude}
                                                               Photos Urls: ${e.photos}
                                                               Price: ${e.price}
                                                               Region: ${e.region}
                                                               Terms: ${e.terms}
                                                               Video Url: ${e.videoUrl}
                                                              '''
                                                          ], 'text/plan', 'native');
                                                          webFile.AnchorElement(
                                                            href:
                                                                webFile.Url.createObjectUrlFromBlob(blob)
                                                                    .toString(),
                                                          )
                                                            ..setAttribute("download", "${e.name}.txt")
                                                            ..click();
                                                        }
                                                        await FirebaseFirestore.instance
                                                            .collection('lodges')
                                                            .doc(e.id)
                                                            .update({'archive': true});
                                                        getallData();
                                                      },
                                                      child: Image.asset(
                                                        'assets/icons/archive.png',
                                                        scale: 4,
                                                      ),
                                                    ),
                                                    SizedBox(height: 5),
                                                    Text(
                                                      'Archive',
                                                      style: TextStyle(
                                                          fontSize: 13,
                                                          fontWeight: FontWeight.w500,
                                                          color: kPrimary1),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              DataCell(
                                                Column(
                                                  children: [
                                                    SizedBox(height: 20),
                                                    InkWell(
                                                      onTap: () {
                                                        //TODO add dulicate lodge in firebase
                                                      },
                                                      child: Image.asset(
                                                        'assets/icons/copy.png',
                                                        scale: 4,
                                                      ),
                                                    ),
                                                    SizedBox(height: 5),
                                                    Text(
                                                      'Duplicate',
                                                      style: TextStyle(
                                                          fontSize: 13,
                                                          fontWeight: FontWeight.w500,
                                                          color: kPrimary1),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ]))
                                        .toList()),
                              ),
                        //rejected lodges
                        isLoading
                            ? Center(
                                child: SizedBox(
                                  width: 150,
                                  height: 150,
                                  child: LoadingIndicator(
                                    indicatorType: Indicator.orbit,
                                    colors: [Colors.red, Colors.blue],
                                  ),
                                ),
                              )
                            : InteractiveViewer(
                                scaleEnabled: false,
                                constrained: false,
                                child: DataTable(
                                    dataRowHeight: 80.0,
                                    //horizontalMargin: 46,
                                    headingTextStyle: TextStyle(
                                        fontSize: 14, fontWeight: FontWeight.w600, color: kUIDark),
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
                                        label: Text(''),
                                      ),
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
                                        label: Text('Set Inactive/\nActive'),
                                      ),
                                      DataColumn(
                                        label: Text(''),
                                      ),
                                      DataColumn(
                                        label: Text(''),
                                      ),
                                      DataColumn(
                                        label: Text(''),
                                      ),
                                      DataColumn(
                                        label: Text(''),
                                      ),
                                    ],
                                    rows: rejectedLodges
                                        .map((e) => DataRow(cells: [
                                              DataCell(
                                                Row(
                                                  children: [
                                                    InkWell(
                                                      onTap: () {
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder: (context) => EditProduct(
                                                                      lodgedata: e,
                                                                      edit: true,
                                                                    )));
                                                      },
                                                      child: Image.asset(
                                                        'assets/icons/pencil.png',
                                                        scale: 4,
                                                      ),
                                                    ),
                                                    SizedBox(width: 11.5),
                                                    Text(
                                                      'Edit',
                                                      style: TextStyle(color: kUILight2),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              DataCell(
                                                Text(
                                                  e.name!,
                                                  style: TextStyle(
                                                    color: kUIDark,
                                                  ),
                                                ),
                                              ),
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
                                                Transform.scale(
                                                  scale: 0.8,
                                                  child: CupertinoSwitch(
                                                      value: e.status == 'active' ? true : false,
                                                      onChanged: (value) async {
                                                        setState(() {
                                                          if (value) {
                                                            e.status = 'active';
                                                          } else {
                                                            e.status = 'pending';
                                                          }
                                                        });
                                                        await FirebaseFirestore.instance
                                                            .collection('lodges')
                                                            .doc(e.id)
                                                            .update({'status': e.status});
                                                        getallData();
                                                      }),
                                                ),
                                              ),
                                              DataCell(
                                                Column(
                                                  children: [
                                                    SizedBox(height: 20),
                                                    InkWell(
                                                      onTap: () {
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder: (context) =>
                                                                    EditProduct(lodgedata: e)));
                                                      },
                                                      child: Image.asset(
                                                        'assets/icons/eye.png',
                                                        scale: 4,
                                                      ),
                                                    ),
                                                    SizedBox(height: 5),
                                                    Text(
                                                      'View',
                                                      style: TextStyle(
                                                          fontSize: 13,
                                                          fontWeight: FontWeight.w500,
                                                          color: kPrimary1),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              DataCell(
                                                Column(
                                                  children: [
                                                    SizedBox(height: 20),
                                                    InkWell(
                                                      onTap: () {
                                                        //TODO what we need to share
                                                        Share.share('What we are going to share');
                                                      },
                                                      child: Image.asset(
                                                        'assets/icons/share.png',
                                                        scale: 4,
                                                      ),
                                                    ),
                                                    SizedBox(height: 5),
                                                    Text(
                                                      'Share',
                                                      style: TextStyle(
                                                          fontSize: 13,
                                                          fontWeight: FontWeight.w500,
                                                          color: kPrimary1),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              DataCell(
                                                Column(
                                                  children: [
                                                    SizedBox(height: 20),
                                                    InkWell(
                                                      onTap: () async {
                                                        if (kIsWeb) {
                                                          var blob = webFile.Blob([
                                                            '''Name: ${e.name}
                                                              Category: ${e.category}
                                                               Description: ${e.description}
                                                               Latitude: ${e.latitude}
                                                               Longitude: ${e.longitude}
                                                               Photos Urls: ${e.photos}
                                                               Price: ${e.price}
                                                               Region: ${e.region}
                                                               Terms: ${e.terms}
                                                               Video Url: ${e.videoUrl}
                                                              '''
                                                          ], 'text/plan', 'native');
                                                          webFile.AnchorElement(
                                                            href:
                                                                webFile.Url.createObjectUrlFromBlob(blob)
                                                                    .toString(),
                                                          )
                                                            ..setAttribute("download", "${e.name}.txt")
                                                            ..click();
                                                        }
                                                        await FirebaseFirestore.instance
                                                            .collection('lodges')
                                                            .doc(e.id)
                                                            .update({'archive': true});
                                                        getallData();
                                                      },
                                                      child: Image.asset(
                                                        'assets/icons/archive.png',
                                                        scale: 4,
                                                      ),
                                                    ),
                                                    SizedBox(height: 5),
                                                    Text(
                                                      'Archive',
                                                      style: TextStyle(
                                                          fontSize: 13,
                                                          fontWeight: FontWeight.w500,
                                                          color: kPrimary1),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              DataCell(
                                                Column(
                                                  children: [
                                                    SizedBox(height: 20),
                                                    InkWell(
                                                      onTap: () {
                                                        //TODO add dulicate lodge in firebase
                                                      },
                                                      child: Image.asset(
                                                        'assets/icons/copy.png',
                                                        scale: 4,
                                                      ),
                                                    ),
                                                    SizedBox(height: 5),
                                                    Text(
                                                      'Duplicate',
                                                      style: TextStyle(
                                                          fontSize: 13,
                                                          fontWeight: FontWeight.w500,
                                                          color: kPrimary1),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ]))
                                        .toList()),
                              ),
                        //pending lodges
                        isLoading
                            ? Center(
                                child: SizedBox(
                                  width: 150,
                                  height: 150,
                                  child: LoadingIndicator(
                                    indicatorType: Indicator.orbit,
                                    colors: [Colors.red, Colors.blue],
                                  ),
                                ),
                              )
                            : InteractiveViewer(
                                scaleEnabled: false,
                                constrained: false,
                                child: DataTable(
                                    dataRowHeight: 80.0,
                                    //horizontalMargin: 46,
                                    headingTextStyle: TextStyle(
                                        fontSize: 14, fontWeight: FontWeight.w600, color: kUIDark),
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
                                        label: Text(''),
                                      ),
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
                                        label: Text('Set Inactive/\nActive'),
                                      ),
                                      DataColumn(
                                        label: Text(''),
                                      ),
                                      DataColumn(
                                        label: Text(''),
                                      ),
                                      DataColumn(
                                        label: Text(''),
                                      ),
                                      DataColumn(
                                        label: Text(''),
                                      ),
                                    ],
                                    rows: pendingLodges
                                        .map((e) => DataRow(cells: [
                                              DataCell(
                                                Row(
                                                  children: [
                                                    InkWell(
                                                      onTap: () {
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder: (context) => EditProduct(
                                                                      lodgedata: e,
                                                                      edit: true,
                                                                    )));
                                                      },
                                                      child: Image.asset(
                                                        'assets/icons/pencil.png',
                                                        scale: 4,
                                                      ),
                                                    ),
                                                    SizedBox(width: 11.5),
                                                    Text(
                                                      'Edit',
                                                      style: TextStyle(color: kUILight2),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              DataCell(
                                                Text(
                                                  e.name!,
                                                  style: TextStyle(
                                                    color: kUIDark,
                                                  ),
                                                ),
                                              ),
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
                                                Transform.scale(
                                                  scale: 0.8,
                                                  child: CupertinoSwitch(
                                                      value: e.status == 'active' ? true : false,
                                                      onChanged: (value) async {
                                                        setState(() {
                                                          if (value) {
                                                            e.status = 'active';
                                                          } else {
                                                            e.status = 'pending';
                                                          }
                                                        });
                                                        await FirebaseFirestore.instance
                                                            .collection('lodges')
                                                            .doc(e.id)
                                                            .update({'status': e.status});
                                                        getallData();
                                                      }),
                                                ),
                                              ),
                                              DataCell(
                                                Column(
                                                  children: [
                                                    SizedBox(height: 20),
                                                    InkWell(
                                                      onTap: () {
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder: (context) =>
                                                                    EditProduct(lodgedata: e)));
                                                      },
                                                      child: Image.asset(
                                                        'assets/icons/eye.png',
                                                        scale: 4,
                                                      ),
                                                    ),
                                                    SizedBox(height: 5),
                                                    Text(
                                                      'View',
                                                      style: TextStyle(
                                                          fontSize: 13,
                                                          fontWeight: FontWeight.w500,
                                                          color: kPrimary1),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              DataCell(
                                                Column(
                                                  children: [
                                                    SizedBox(height: 20),
                                                    InkWell(
                                                      onTap: () {
                                                        //TODO what we need to share
                                                        Share.share('What we are going to share');
                                                      },
                                                      child: Image.asset(
                                                        'assets/icons/share.png',
                                                        scale: 4,
                                                      ),
                                                    ),
                                                    SizedBox(height: 5),
                                                    Text(
                                                      'Share',
                                                      style: TextStyle(
                                                          fontSize: 13,
                                                          fontWeight: FontWeight.w500,
                                                          color: kPrimary1),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              DataCell(
                                                Column(
                                                  children: [
                                                    SizedBox(height: 20),
                                                    InkWell(
                                                      onTap: () async {
                                                        if (kIsWeb) {
                                                          var blob = webFile.Blob([
                                                            '''Name: ${e.name}
                                                              Category: ${e.category}
                                                               Description: ${e.description}
                                                               Latitude: ${e.latitude}
                                                               Longitude: ${e.longitude}
                                                               Photos Urls: ${e.photos}
                                                               Price: ${e.price}
                                                               Region: ${e.region}
                                                               Terms: ${e.terms}
                                                               Video Url: ${e.videoUrl}
                                                              '''
                                                          ], 'text/plan', 'native');
                                                          webFile.AnchorElement(
                                                            href:
                                                                webFile.Url.createObjectUrlFromBlob(blob)
                                                                    .toString(),
                                                          )
                                                            ..setAttribute("download", "${e.name}.txt")
                                                            ..click();
                                                        }
                                                        await FirebaseFirestore.instance
                                                            .collection('lodges')
                                                            .doc(e.id)
                                                            .update({'archive': true});
                                                        getallData();
                                                      },
                                                      child: Image.asset(
                                                        'assets/icons/archive.png',
                                                        scale: 4,
                                                      ),
                                                    ),
                                                    SizedBox(height: 5),
                                                    Text(
                                                      'Archive',
                                                      style: TextStyle(
                                                          fontSize: 13,
                                                          fontWeight: FontWeight.w500,
                                                          color: kPrimary1),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              DataCell(
                                                Column(
                                                  children: [
                                                    SizedBox(height: 20),
                                                    InkWell(
                                                      onTap: () {
                                                        //TODO add dulicate lodge in firebase
                                                      },
                                                      child: Image.asset(
                                                        'assets/icons/copy.png',
                                                        scale: 4,
                                                      ),
                                                    ),
                                                    SizedBox(height: 5),
                                                    Text(
                                                      'Duplicate',
                                                      style: TextStyle(
                                                          fontSize: 13,
                                                          fontWeight: FontWeight.w500,
                                                          color: kPrimary1),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ]))
                                        .toList()),
                              ),
                        //inactive lodges
                        isLoading
                            ? Center(
                                child: SizedBox(
                                  width: 150,
                                  height: 150,
                                  child: LoadingIndicator(
                                    indicatorType: Indicator.orbit,
                                    colors: [Colors.red, Colors.blue],
                                  ),
                                ),
                              )
                            : InteractiveViewer(
                                scaleEnabled: false,
                                constrained: false,
                                child: DataTable(
                                    dataRowHeight: 80.0,
                                    //horizontalMargin: 46,
                                    headingTextStyle: TextStyle(
                                        fontSize: 14, fontWeight: FontWeight.w600, color: kUIDark),
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
                                        label: Text(''),
                                      ),
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
                                        label: Text('Set Inactive/\nActive'),
                                      ),
                                      DataColumn(
                                        label: Text(''),
                                      ),
                                      DataColumn(
                                        label: Text(''),
                                      ),
                                      DataColumn(
                                        label: Text(''),
                                      ),
                                      DataColumn(
                                        label: Text(''),
                                      ),
                                    ],
                                    rows: inactiveLodges
                                        .map((e) => DataRow(cells: [
                                              DataCell(
                                                Row(
                                                  children: [
                                                    InkWell(
                                                      onTap: () {
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder: (context) => EditProduct(
                                                                      lodgedata: e,
                                                                      edit: true,
                                                                    )));
                                                      },
                                                      child: Image.asset(
                                                        'assets/icons/pencil.png',
                                                        scale: 4,
                                                      ),
                                                    ),
                                                    SizedBox(width: 11.5),
                                                    Text(
                                                      'Edit',
                                                      style: TextStyle(color: kUILight2),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              DataCell(
                                                Text(
                                                  e.name!,
                                                  style: TextStyle(
                                                    color: kUIDark,
                                                  ),
                                                ),
                                              ),
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
                                                Transform.scale(
                                                  scale: 0.8,
                                                  child: CupertinoSwitch(
                                                      value: e.status == 'active' ? true : false,
                                                      onChanged: (value) async {
                                                        setState(() {
                                                          if (value) {
                                                            e.status = 'active';
                                                          } else {
                                                            e.status = 'pending';
                                                          }
                                                        });
                                                        await FirebaseFirestore.instance
                                                            .collection('lodges')
                                                            .doc(e.id)
                                                            .update({'status': e.status});
                                                        getallData();
                                                      }),
                                                ),
                                              ),
                                              DataCell(
                                                Column(
                                                  children: [
                                                    SizedBox(height: 20),
                                                    InkWell(
                                                      onTap: () {
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder: (context) =>
                                                                    EditProduct(lodgedata: e)));
                                                      },
                                                      child: Image.asset(
                                                        'assets/icons/eye.png',
                                                        scale: 4,
                                                      ),
                                                    ),
                                                    SizedBox(height: 5),
                                                    Text(
                                                      'View',
                                                      style: TextStyle(
                                                          fontSize: 13,
                                                          fontWeight: FontWeight.w500,
                                                          color: kPrimary1),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              DataCell(
                                                Column(
                                                  children: [
                                                    SizedBox(height: 20),
                                                    InkWell(
                                                      onTap: () {
                                                        //TODO what we need to share
                                                        Share.share('What we are going to share');
                                                      },
                                                      child: Image.asset(
                                                        'assets/icons/share.png',
                                                        scale: 4,
                                                      ),
                                                    ),
                                                    SizedBox(height: 5),
                                                    Text(
                                                      'Share',
                                                      style: TextStyle(
                                                          fontSize: 13,
                                                          fontWeight: FontWeight.w500,
                                                          color: kPrimary1),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              DataCell(
                                                Column(
                                                  children: [
                                                    SizedBox(height: 20),
                                                    InkWell(
                                                      onTap: () async {
                                                        if (kIsWeb) {
                                                          var blob = webFile.Blob([
                                                            '''Name: ${e.name}
                                                              Category: ${e.category}
                                                               Description: ${e.description}
                                                               Latitude: ${e.latitude}
                                                               Longitude: ${e.longitude}
                                                               Photos Urls: ${e.photos}
                                                               Price: ${e.price}
                                                               Region: ${e.region}
                                                               Terms: ${e.terms}
                                                               Video Url: ${e.videoUrl}
                                                              '''
                                                          ], 'text/plan', 'native');
                                                          webFile.AnchorElement(
                                                            href:
                                                                webFile.Url.createObjectUrlFromBlob(blob)
                                                                    .toString(),
                                                          )
                                                            ..setAttribute("download", "${e.name}.txt")
                                                            ..click();
                                                        }
                                                        await FirebaseFirestore.instance
                                                            .collection('lodges')
                                                            .doc(e.id)
                                                            .update({'archive': true});
                                                        getallData();
                                                      },
                                                      child: Image.asset(
                                                        'assets/icons/archive.png',
                                                        scale: 4,
                                                      ),
                                                    ),
                                                    SizedBox(height: 5),
                                                    Text(
                                                      'Archive',
                                                      style: TextStyle(
                                                          fontSize: 13,
                                                          fontWeight: FontWeight.w500,
                                                          color: kPrimary1),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              DataCell(
                                                Column(
                                                  children: [
                                                    SizedBox(height: 20),
                                                    InkWell(
                                                      onTap: () {
                                                        //TODO add dulicate lodge in firebase
                                                      },
                                                      child: Image.asset(
                                                        'assets/icons/copy.png',
                                                        scale: 4,
                                                      ),
                                                    ),
                                                    SizedBox(height: 5),
                                                    Text(
                                                      'Duplicate',
                                                      style: TextStyle(
                                                          fontSize: 13,
                                                          fontWeight: FontWeight.w500,
                                                          color: kPrimary1),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ]))
                                        .toList()),
                              ),

                        //live lodges
                        isLoading
                            ? Center(
                                child: SizedBox(
                                  width: 150,
                                  height: 150,
                                  child: LoadingIndicator(
                                    indicatorType: Indicator.orbit,
                                    colors: [Colors.red, Colors.blue],
                                  ),
                                ),
                              )
                            : InteractiveViewer(
                                scaleEnabled: false,
                                constrained: false,
                                child: DataTable(
                                    dataRowHeight: 80.0,
                                    //horizontalMargin: 46,
                                    headingTextStyle: TextStyle(
                                        fontSize: 14, fontWeight: FontWeight.w600, color: kUIDark),
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
                                        label: Text(''),
                                      ),
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
                                        label: Text('Set Inactive/\nActive'),
                                      ),
                                      DataColumn(
                                        label: Text(''),
                                      ),
                                      DataColumn(
                                        label: Text(''),
                                      ),
                                      DataColumn(
                                        label: Text(''),
                                      ),
                                      DataColumn(
                                        label: Text(''),
                                      ),
                                    ],
                                    rows: liveLodges
                                        .map((e) => DataRow(cells: [
                                              DataCell(
                                                Row(
                                                  children: [
                                                    InkWell(
                                                      onTap: () {
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder: (context) => EditProduct(
                                                                      lodgedata: e,
                                                                      edit: true,
                                                                    )));
                                                      },
                                                      child: Image.asset(
                                                        'assets/icons/pencil.png',
                                                        scale: 4,
                                                      ),
                                                    ),
                                                    SizedBox(width: 11.5),
                                                    Text(
                                                      'Edit',
                                                      style: TextStyle(color: kUILight2),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              DataCell(
                                                Text(
                                                  e.name!,
                                                  style: TextStyle(
                                                    color: kUIDark,
                                                  ),
                                                ),
                                              ),
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
                                                Transform.scale(
                                                  scale: 0.8,
                                                  child: CupertinoSwitch(
                                                      value: e.status == 'active' ? true : false,
                                                      onChanged: (value) async {
                                                        setState(() {
                                                          if (value) {
                                                            e.status = 'active';
                                                          } else {
                                                            e.status = 'pending';
                                                          }
                                                        });
                                                        await FirebaseFirestore.instance
                                                            .collection('lodges')
                                                            .doc(e.id)
                                                            .update({'status': e.status});
                                                        getallData();
                                                      }),
                                                ),
                                              ),
                                              DataCell(
                                                Column(
                                                  children: [
                                                    SizedBox(height: 20),
                                                    InkWell(
                                                      onTap: () {
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder: (context) =>
                                                                    EditProduct(lodgedata: e)));
                                                      },
                                                      child: Image.asset(
                                                        'assets/icons/eye.png',
                                                        scale: 4,
                                                      ),
                                                    ),
                                                    SizedBox(height: 5),
                                                    Text(
                                                      'View',
                                                      style: TextStyle(
                                                          fontSize: 13,
                                                          fontWeight: FontWeight.w500,
                                                          color: kPrimary1),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              DataCell(
                                                Column(
                                                  children: [
                                                    SizedBox(height: 20),
                                                    InkWell(
                                                      onTap: () {
                                                        //TODO what we need to share
                                                        Share.share('What we are going to share');
                                                      },
                                                      child: Image.asset(
                                                        'assets/icons/share.png',
                                                        scale: 4,
                                                      ),
                                                    ),
                                                    SizedBox(height: 5),
                                                    Text(
                                                      'Share',
                                                      style: TextStyle(
                                                          fontSize: 13,
                                                          fontWeight: FontWeight.w500,
                                                          color: kPrimary1),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              DataCell(
                                                Column(
                                                  children: [
                                                    SizedBox(height: 20),
                                                    InkWell(
                                                      onTap: () async {
                                                        if (kIsWeb) {
                                                          var blob = webFile.Blob([
                                                            '''Name: ${e.name}
                                                              Category: ${e.category}
                                                               Description: ${e.description}
                                                               Latitude: ${e.latitude}
                                                               Longitude: ${e.longitude}
                                                               Photos Urls: ${e.photos}
                                                               Price: ${e.price}
                                                               Region: ${e.region}
                                                               Terms: ${e.terms}
                                                               Video Url: ${e.videoUrl}
                                                              '''
                                                          ], 'text/plan', 'native');
                                                          webFile.AnchorElement(
                                                            href:
                                                                webFile.Url.createObjectUrlFromBlob(blob)
                                                                    .toString(),
                                                          )
                                                            ..setAttribute("download", "${e.name}.txt")
                                                            ..click();
                                                        }
                                                        await FirebaseFirestore.instance
                                                            .collection('lodges')
                                                            .doc(e.id)
                                                            .update({'archive': true});
                                                        getallData();
                                                      },
                                                      child: Image.asset(
                                                        'assets/icons/archive.png',
                                                        scale: 4,
                                                      ),
                                                    ),
                                                    SizedBox(height: 5),
                                                    Text(
                                                      'Archive',
                                                      style: TextStyle(
                                                          fontSize: 13,
                                                          fontWeight: FontWeight.w500,
                                                          color: kPrimary1),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              DataCell(
                                                Column(
                                                  children: [
                                                    SizedBox(height: 20),
                                                    InkWell(
                                                      onTap: () {
                                                        //TODO add dulicate lodge in firebase
                                                      },
                                                      child: Image.asset(
                                                        'assets/icons/copy.png',
                                                        scale: 4,
                                                      ),
                                                    ),
                                                    SizedBox(height: 5),
                                                    Text(
                                                      'Duplicate',
                                                      style: TextStyle(
                                                          fontSize: 13,
                                                          fontWeight: FontWeight.w500,
                                                          color: kPrimary1),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ]))
                                        .toList()),
                              ),

                        //archived
                        isLoading
                            ? Center(
                                child: SizedBox(
                                  width: 150,
                                  height: 150,
                                  child: LoadingIndicator(
                                    indicatorType: Indicator.orbit,
                                    colors: [Colors.red, Colors.blue],
                                  ),
                                ),
                              )
                            : InteractiveViewer(
                                scaleEnabled: false,
                                constrained: false,
                                child: DataTable(
                                    dataRowHeight: 80.0,
                                    //horizontalMargin: 46,
                                    headingTextStyle: TextStyle(
                                        fontSize: 14, fontWeight: FontWeight.w600, color: kUIDark),
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
                                        label: Text(''),
                                      ),
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
                                        label: Text('Set Inactive/\nActive'),
                                      ),
                                      DataColumn(
                                        label: Text(''),
                                      ),
                                      DataColumn(
                                        label: Text(''),
                                      ),
                                      DataColumn(
                                        label: Text(''),
                                      ),
                                      DataColumn(
                                        label: Text(''),
                                      ),
                                    ],
                                    rows: archiveLodges
                                        .map((e) => DataRow(cells: [
                                              DataCell(
                                                Row(
                                                  children: [
                                                    InkWell(
                                                      onTap: () {
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder: (context) => EditProduct(
                                                                      lodgedata: e,
                                                                      edit: true,
                                                                    )));
                                                      },
                                                      child: Image.asset(
                                                        'assets/icons/pencil.png',
                                                        scale: 4,
                                                      ),
                                                    ),
                                                    SizedBox(width: 11.5),
                                                    Text(
                                                      'Edit',
                                                      style: TextStyle(color: kUILight2),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              DataCell(
                                                Text(
                                                  e.name!,
                                                  style: TextStyle(
                                                    color: kUIDark,
                                                  ),
                                                ),
                                              ),
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
                                                Transform.scale(
                                                  scale: 0.8,
                                                  child: CupertinoSwitch(
                                                      value: e.status == 'active' ? true : false,
                                                      onChanged: (value) async {
                                                        setState(() {
                                                          if (value) {
                                                            e.status = 'active';
                                                          } else {
                                                            e.status = 'pending';
                                                          }
                                                        });
                                                        await FirebaseFirestore.instance
                                                            .collection('lodges')
                                                            .doc(e.id)
                                                            .update({'status': e.status});
                                                        getallData();
                                                      }),
                                                ),
                                              ),
                                              DataCell(
                                                Column(
                                                  children: [
                                                    SizedBox(height: 20),
                                                    InkWell(
                                                      onTap: () {
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder: (context) =>
                                                                    EditProduct(lodgedata: e)));
                                                      },
                                                      child: Image.asset(
                                                        'assets/icons/eye.png',
                                                        scale: 4,
                                                      ),
                                                    ),
                                                    SizedBox(height: 5),
                                                    Text(
                                                      'View',
                                                      style: TextStyle(
                                                          fontSize: 13,
                                                          fontWeight: FontWeight.w500,
                                                          color: kPrimary1),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              DataCell(
                                                Column(
                                                  children: [
                                                    SizedBox(height: 20),
                                                    InkWell(
                                                      onTap: () {
                                                        //TODO what we need to share
                                                        Share.share('What we are going to share');
                                                      },
                                                      child: Image.asset(
                                                        'assets/icons/share.png',
                                                        scale: 4,
                                                      ),
                                                    ),
                                                    SizedBox(height: 5),
                                                    Text(
                                                      'Share',
                                                      style: TextStyle(
                                                          fontSize: 13,
                                                          fontWeight: FontWeight.w500,
                                                          color: kPrimary1),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              DataCell(
                                                Column(
                                                  children: [
                                                    SizedBox(height: 20),
                                                    InkWell(
                                                      onTap: () async {
                                                        if (kIsWeb) {
                                                          var blob = webFile.Blob([
                                                            '''Name: ${e.name}
                                                              Category: ${e.category}
                                                               Description: ${e.description}
                                                               Latitude: ${e.latitude}
                                                               Longitude: ${e.longitude}
                                                               Photos Urls: ${e.photos}
                                                               Price: ${e.price}
                                                               Region: ${e.region}
                                                               Terms: ${e.terms}
                                                               Video Url: ${e.videoUrl}
                                                              '''
                                                          ], 'text/plan', 'native');
                                                          webFile.AnchorElement(
                                                            href:
                                                                webFile.Url.createObjectUrlFromBlob(blob)
                                                                    .toString(),
                                                          )
                                                            ..setAttribute("download", "${e.name}.txt")
                                                            ..click();
                                                        }
                                                        await FirebaseFirestore.instance
                                                            .collection('lodges')
                                                            .doc(e.id)
                                                            .update({'archive': true});
                                                        getallData();
                                                      },
                                                      child: Image.asset(
                                                        'assets/icons/archive.png',
                                                        scale: 4,
                                                      ),
                                                    ),
                                                    SizedBox(height: 5),
                                                    Text(
                                                      'Archive',
                                                      style: TextStyle(
                                                          fontSize: 13,
                                                          fontWeight: FontWeight.w500,
                                                          color: kPrimary1),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              DataCell(
                                                Column(
                                                  children: [
                                                    SizedBox(height: 20),
                                                    InkWell(
                                                      onTap: () {
                                                        //TODO add dulicate lodge in firebase
                                                      },
                                                      child: Image.asset(
                                                        'assets/icons/copy.png',
                                                        scale: 4,
                                                      ),
                                                    ),
                                                    SizedBox(height: 5),
                                                    Text(
                                                      'Duplicate',
                                                      style: TextStyle(
                                                          fontSize: 13,
                                                          fontWeight: FontWeight.w500,
                                                          color: kPrimary1),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ]))
                                        .toList()),
                              ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future getallData() async {
    try {
      setState(() {
        isLoading = true;
      });
      QuerySnapshot snap =
          await FirebaseFirestore.instance.collection('compnies').where('id', isEqualTo: user.uid).get();
      setState(() {
        data = CompanyData.fromMap(snap.docs.first.data() as Map<String, dynamic>);
      });
      QuerySnapshot lodgeSnap = await FirebaseFirestore.instance
          .collection('lodges')
          .where('companyid', isEqualTo: user.uid)
          .get();

      if (lodgeSnap.docs.isNotEmpty) {
        setState(() {
          lodgeData =
              lodgeSnap.docs.map((e) => LodgeData.fromMap(e.data() as Map<String, dynamic>)).toList();
          temp = lodgeData;
          lodgeNames = lodgeData.map((e) => e.name!).toList();
          acceptedLodges = lodgeData.where((element) => element.adminStatus == 'Accepted').toList();
          rejectedLodges = lodgeData.where((element) => element.adminStatus == 'Declined').toList();
          pendingLodges = lodgeData.where((element) => element.adminStatus == 'Pending').toList();
          inactiveLodges = lodgeData.where((element) => element.status == 'pending').toList();
          liveLodges = lodgeData.where((element) => element.status == 'active').toList();
          archiveLodges = lodgeData.where((element) => element.archive == true).toList();
        });
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
      isLoading = false;
      setState(() {});
    }
  }

  getAllDatabyName(String value) {
    try {
      setState(() {
        lodgeData = temp.where((element) => element.name == value).toList();
        acceptedLodges = lodgeData.where((element) => element.adminStatus == 'Accepted').toList();
        rejectedLodges = lodgeData.where((element) => element.adminStatus == 'Declined').toList();
        pendingLodges = lodgeData.where((element) => element.adminStatus == 'Pending').toList();
        inactiveLodges = lodgeData.where((element) => element.status == 'pending').toList();
        liveLodges = lodgeData.where((element) => element.status == 'active').toList();
        archiveLodges = lodgeData.where((element) => element.archive == true).toList();
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
    }
  }

  getAllDatabyAll() {
    try {
      setState(() {
        lodgeData = temp;
        acceptedLodges = lodgeData.where((element) => element.adminStatus == 'Accepted').toList();
        rejectedLodges = lodgeData.where((element) => element.adminStatus == 'Declined').toList();
        pendingLodges = lodgeData.where((element) => element.adminStatus == 'Pending').toList();
        inactiveLodges = lodgeData.where((element) => element.status == 'pending').toList();
        liveLodges = lodgeData.where((element) => element.status == 'active').toList();
        archiveLodges = lodgeData.where((element) => element.archive == true).toList();
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
    }
  }
}
