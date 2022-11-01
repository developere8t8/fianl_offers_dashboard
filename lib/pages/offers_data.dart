// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:countdown_progress_indicator/countdown_progress_indicator.dart';
import 'package:fianl_offer_dashboard/models/company.dart';
import 'package:fianl_offer_dashboard/models/lodge.dart';
import 'package:fianl_offer_dashboard/models/offers.dart';
import 'package:fianl_offer_dashboard/models/viewer.dart';
import 'package:fianl_offer_dashboard/pages/new_product.dart';
import 'package:fianl_offer_dashboard/widgets/button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import '../constants.dart';
import '../widgets/error.dart';

class MyOffers extends StatefulWidget {
  const MyOffers({
    Key? key,
  }) : super(key: key);

  @override
  State<MyOffers> createState() => _MyOffersState();
}

class _MyOffersState extends State<MyOffers> {
  TextEditingController search = TextEditingController();
  final user = FirebaseAuth.instance.currentUser!;
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();

  List<OffersData> offersData = [];
  List<OffersData> selectOffers = [];
  List<OfferViewerData> offersViewer = [];
  List<OfferViewerData> temp = []; //for search items storage
  List<OfferViewerData> acceptedoffersViewer = [];
  List<OfferViewerData> rejectoffersViewer = [];
  List<OfferViewerData> pendingoffersViewer = [];
  List<String> lodgeNames = [];
  List<String> selected = [];
  List<String> paymentStatus = ['Paid', 'Not Paid'];
  //List<String> rangeFilter = ['Past 7 days', 'Past 30 days', 'Past 90 days'];
  String status = '';
  CompanyData? data;
  List<String> qureyDays = ['Past 7 days', 'Past 30 days', 'Past 90 days'];
  String selectedQueryDay = 'Past 30 days';
  final _controller = CountDownController();
  bool isLoading = false;
  @override
  void initState() {
    getAllData();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: kColorWhite,
            elevation: 0,
            title: const Text(
              'Offers',
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
                  SizedBox(height: 28),
                  SizedBox(
                    width: 340,
                    height: 47,
                    child: TypeAheadFormField(
                      suggestionsCallback: (patteren) => lodgeNames
                          .where((element) => element.toLowerCase().contains(patteren.toLowerCase())),
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
                        child: Text('No data found'),
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
                  SizedBox(height: 28),
                  Row(
                    //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TabBar(
                        isScrollable: true,
                        labelPadding: EdgeInsets.symmetric(horizontal: 35),
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
                        ],
                      ),
                      SizedBox(
                        width: 100,
                      ),
                      Container(
                        height: 40,
                        //width: 200,
                        decoration: BoxDecoration(border: Border.all(color: kTabBarLine)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              onPressed: () {},
                              icon: Icon(
                                Icons.calendar_today,
                                color: kUILight2,
                                size: 18,
                              ),
                            ),
                            Center(
                                child: DropdownButtonHideUnderline(
                              child: DropdownButton(
                                  dropdownColor: Colors.white,
                                  focusColor: Colors.white,
                                  isDense: true,
                                  value: selectedQueryDay,
                                  borderRadius: BorderRadius.circular(20),
                                  items: qureyDays.map((String items) {
                                    return DropdownMenuItem(
                                      value: items,
                                      child: Text(
                                        items,
                                        style: TextStyle(
                                          color: kPrimary1,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (value) async {
                                    setState(() {
                                      selectedQueryDay = value!;
                                    });
                                    getDataByDays(value);
                                  }),
                            )
                                // Text(
                                //   'Past 90 Days',
                                //   style: GoogleFonts.poppins(
                                //     fontWeight: FontWeight.w400,
                                //     fontSize: 14,
                                //   ),
                                // ),
                                ),
                            // InkWell(
                            //   onTap: () {},
                            //   child: Icon(
                            //     Icons.keyboard_arrow_down,
                            //     size: 23,
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                      Container(
                        height: 40,
                        width: 300,
                        decoration: BoxDecoration(border: Border.all(color: kTabBarLine)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Center(
                                child: Text(
                                  DateFormat('MMM-dd-yyyy').format(startDate),
                                  style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w500, fontSize: 14, color: kPrimary1),
                                ),
                              ),
                              Center(
                                child: Text(
                                  ' to ',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14,
                                    color: Color(0xff8F8F8F),
                                  ),
                                ),
                              ),
                              Center(
                                child: Text(
                                  DateFormat('MMM-dd-yyyy').format(endDate),
                                  style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w500, fontSize: 14, color: kPrimary1),
                                ),
                              ),
                              InkWell(
                                  onTap: () {
                                    showDatePickerDialogue();
                                  },
                                  child: Icon(
                                    Icons.arrow_drop_down,
                                    color: Colors.black,
                                  ))
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                  Divider(
                    height: 1,
                    color: kTabBarLine,
                  ),
                  SizedBox(height: 67),
                  SizedBox(
                    width: 1250,
                    height: 621,
                    child: TabBarView(
                      children: [
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
                                    dataRowHeight: 90.0,
                                    horizontalMargin: 46,
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
                                        label: Text('Product name'),
                                      ),
                                      DataColumn(
                                        label: Text('Your Price'),
                                      ),
                                      DataColumn(
                                        label: Text('Offered'),
                                      ),
                                      DataColumn(
                                        label: Text('Date created'),
                                      ),
                                      DataColumn(
                                        label: Text('Conditions'),
                                      ),
                                      DataColumn(
                                        label: Text('Time Left'),
                                      ),
                                      DataColumn(
                                        label: Text('Payment'),
                                      ),
                                      DataColumn(
                                        label: Text('Accept/Reject'),
                                      ),
                                    ],
                                    rows: offersViewer
                                        .map((e) => DataRow(cells: [
                                              DataCell(
                                                Row(
                                                  children: [
                                                    Checkbox(
                                                      value: e.selected,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(3),
                                                      ),
                                                      onChanged: (value) {
                                                        setState(() {
                                                          e.selected = value;
                                                          if (e.selected!) {
                                                            selected.add(e.id!);
                                                          } else {
                                                            selected.remove(e.id);
                                                          }
                                                        });
                                                      },
                                                    ),
                                                    SizedBox(width: 15),
                                                    Text(
                                                      e.lodgeName!,
                                                      style: TextStyle(
                                                        color: kUIDark,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              DataCell(
                                                Text(
                                                  'R${e.actualAmount}',
                                                  style: TextStyle(
                                                    color: kUIDark,
                                                  ),
                                                ),
                                              ),
                                              DataCell(
                                                Text(
                                                  'R${e.amount}',
                                                  style: TextStyle(
                                                    color: kPrimary1,
                                                  ),
                                                ),
                                              ),
                                              DataCell(
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    SizedBox(height: 20),
                                                    Text(
                                                      DateFormat('dd MM yyyy').format(e.date!.toDate()),
                                                      style: TextStyle(
                                                        color: kUIDark,
                                                      ),
                                                    ),
                                                    SizedBox(height: 8),
                                                    Text(
                                                      'At ${DateFormat('hh:mm a').format(e.date!.toDate())}',
                                                      style: TextStyle(
                                                        color: kUILight2,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              DataCell(
                                                Text(
                                                  e.deadLine!,
                                                  style: TextStyle(
                                                      color: e.deadLine == '24H'
                                                          ? kPrimary2
                                                          : e.deadLine == '48H'
                                                              ? kColorOrange
                                                              : e.deadLine == 'Flexible'
                                                                  ? kColorGreen
                                                                  : kUIDark),
                                                ),
                                              ),
                                              DataCell(
                                                SizedBox(
                                                  height: 90,
                                                  width: 90,
                                                  child: CountDownProgressIndicator(
                                                    controller: _controller,
                                                    timeTextStyle: TextStyle(
                                                      fontWeight: FontWeight.w300,
                                                      fontSize: 10,
                                                      color: kPrimary1,
                                                    ),
                                                    strokeWidth: 4,
                                                    valueColor: kPrimary1,
                                                    backgroundColor: kUILight,
                                                    initialPosition: 0,
                                                    duration: e.waiting!,
                                                    timeFormatter: (seconds) {
                                                      return Duration(seconds: seconds)
                                                          .toString()
                                                          .split('.')[0];
                                                    },
                                                    onComplete: () => null,
                                                  ),
                                                ),
                                              ),
                                              DataCell(
                                                Container(
                                                    decoration: BoxDecoration(
                                                        border: Border.all(
                                                            color: e.paid == 'Not Paid'
                                                                ? kPrimary2
                                                                : kPrimary1,
                                                            width: 1,
                                                            style: BorderStyle.solid),
                                                        borderRadius: BorderRadius.circular(20)),
                                                    width: 90,
                                                    height: 30,
                                                    child: SizedBox(
                                                        width: 50,
                                                        height: 30,
                                                        child: Center(
                                                          child: DropdownButton(
                                                              dropdownColor: Colors.white,
                                                              focusColor: Colors.white,
                                                              isDense: true,
                                                              value: e.paid,
                                                              borderRadius: BorderRadius.circular(20),
                                                              items: paymentStatus.map((String items) {
                                                                return DropdownMenuItem(
                                                                  value: items,
                                                                  child: Text(
                                                                    items,
                                                                    style: TextStyle(
                                                                      color: e.paid == 'Not Paid'
                                                                          ? kPrimary2
                                                                          : kPrimary1,
                                                                      fontSize: 12,
                                                                      fontWeight: FontWeight.w500,
                                                                    ),
                                                                  ),
                                                                );
                                                              }).toList(),
                                                              onChanged: (value) async {
                                                                setState(() {
                                                                  e.paid = value;
                                                                });
                                                                await FirebaseFirestore.instance
                                                                    .collection('offers')
                                                                    .doc(e.id)
                                                                    .update({'paid': e.paid});
                                                              }),
                                                        ))),
                                              ),
                                              DataCell(
                                                Transform.scale(
                                                  scale: 0.8,
                                                  child: CupertinoSwitch(
                                                    value: e.accepted!,
                                                    onChanged: (value) async {
                                                      setState(() {
                                                        e.accepted = value;
                                                        if (e.accepted!) {
                                                          status = 'accepted';
                                                        } else {
                                                          status = 'rejected';
                                                        }
                                                      });
                                                      await FirebaseFirestore.instance
                                                          .collection('offers')
                                                          .doc(e.id)
                                                          .update({'status': status});
                                                      getAllData();
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ]))
                                        .toList()),
                              ),
//accepted offers tab
//starts here
/////////
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
                                constrained: false,
                                scaleEnabled: false,
                                child: DataTable(
                                    dataRowHeight: 90.0,
                                    horizontalMargin: 46,
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
                                        label: Text('Product name'),
                                      ),
                                      DataColumn(
                                        label: Text('Your Price'),
                                      ),
                                      DataColumn(
                                        label: Text('Offered'),
                                      ),
                                      DataColumn(
                                        label: Text('Date created'),
                                      ),
                                      DataColumn(
                                        label: Text('Conditions'),
                                      ),
                                      DataColumn(
                                        label: Text('Time Left'),
                                      ),
                                      DataColumn(
                                        label: Text('Payment'),
                                      ),
                                      DataColumn(
                                        label: Text('Accept/Reject'),
                                      ),
                                    ],
                                    rows: acceptedoffersViewer
                                        .map((e) => DataRow(cells: [
                                              DataCell(
                                                Row(
                                                  children: [
                                                    Checkbox(
                                                      value: e.selected,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(3),
                                                      ),
                                                      onChanged: (value) {
                                                        setState(() {
                                                          e.selected = value;
                                                          if (e.selected!) {
                                                            selected.add(e.id!);
                                                          } else {
                                                            selected.remove(e.id);
                                                          }
                                                        });
                                                      },
                                                    ),
                                                    SizedBox(width: 15),
                                                    Text(
                                                      e.lodgeName!,
                                                      style: TextStyle(
                                                        color: kUIDark,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              DataCell(
                                                Text(
                                                  'R${e.actualAmount}',
                                                  style: TextStyle(
                                                    color: kUIDark,
                                                  ),
                                                ),
                                              ),
                                              DataCell(
                                                Text(
                                                  'R${e.amount}',
                                                  style: TextStyle(
                                                    color: kPrimary1,
                                                  ),
                                                ),
                                              ),
                                              DataCell(
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    SizedBox(height: 20),
                                                    Text(
                                                      DateFormat('dd MM yyyy').format(e.date!.toDate()),
                                                      style: TextStyle(
                                                        color: kUIDark,
                                                      ),
                                                    ),
                                                    SizedBox(height: 8),
                                                    Text(
                                                      'At ${DateFormat('hh:mm a').format(e.date!.toDate())}',
                                                      style: TextStyle(
                                                        color: kUILight2,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              DataCell(
                                                Text(
                                                  e.deadLine!,
                                                  style: TextStyle(
                                                      color: e.deadLine == '24H'
                                                          ? kPrimary2
                                                          : e.deadLine == '48H'
                                                              ? kColorOrange
                                                              : e.deadLine == 'Flexible'
                                                                  ? kColorGreen
                                                                  : kUIDark),
                                                ),
                                              ),
                                              DataCell(
                                                SizedBox(
                                                  height: 90,
                                                  width: 90,
                                                  child: CountDownProgressIndicator(
                                                    controller: _controller,
                                                    timeTextStyle: TextStyle(
                                                      fontWeight: FontWeight.w300,
                                                      fontSize: 10,
                                                      color: kPrimary1,
                                                    ),
                                                    strokeWidth: 4,
                                                    valueColor: kPrimary1,
                                                    backgroundColor: kUILight,
                                                    initialPosition: 0,
                                                    duration: e.waiting!,
                                                    timeFormatter: (seconds) {
                                                      return Duration(seconds: seconds)
                                                          .toString()
                                                          .split('.')[0];
                                                    },
                                                    onComplete: () => null,
                                                  ),
                                                ),
                                              ),
                                              DataCell(
                                                Container(
                                                    decoration: BoxDecoration(
                                                        border: Border.all(
                                                            color: e.paid == 'Not Paid'
                                                                ? kPrimary2
                                                                : kPrimary1,
                                                            width: 1,
                                                            style: BorderStyle.solid),
                                                        borderRadius: BorderRadius.circular(20)),
                                                    width: 90,
                                                    height: 30,
                                                    child: SizedBox(
                                                        width: 50,
                                                        height: 30,
                                                        child: Center(
                                                          child: DropdownButton(
                                                              dropdownColor: Colors.white,
                                                              focusColor: Colors.white,
                                                              isDense: true,
                                                              value: e.paid,
                                                              borderRadius: BorderRadius.circular(20),
                                                              items: paymentStatus.map((String items) {
                                                                return DropdownMenuItem(
                                                                  value: items,
                                                                  child: Text(
                                                                    items,
                                                                    style: TextStyle(
                                                                      color: e.paid == 'Not Paid'
                                                                          ? kPrimary2
                                                                          : kPrimary1,
                                                                      fontSize: 12,
                                                                      fontWeight: FontWeight.w500,
                                                                    ),
                                                                  ),
                                                                );
                                                              }).toList(),
                                                              onChanged: (value) async {
                                                                setState(() {
                                                                  e.paid = value;
                                                                });
                                                                await FirebaseFirestore.instance
                                                                    .collection('offers')
                                                                    .doc(e.id)
                                                                    .update({'paid': e.paid});
                                                              }),
                                                        ))),
                                              ),
                                              DataCell(
                                                Transform.scale(
                                                  scale: 0.8,
                                                  child: CupertinoSwitch(
                                                    value: e.accepted!,
                                                    onChanged: (value) async {
                                                      setState(() {
                                                        e.accepted = value;
                                                        if (e.accepted!) {
                                                          status = 'accepted';
                                                        } else {
                                                          status = 'rejected';
                                                        }
                                                      });
                                                      await FirebaseFirestore.instance
                                                          .collection('offers')
                                                          .doc(e.id)
                                                          .update({'status': status});
                                                      getAllData();
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ]))
                                        .toList()),
                              ),
                        //Declined offers tab
//starts here
/////////
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
                                constrained: false,
                                scaleEnabled: false,
                                child: DataTable(
                                    dataRowHeight: 90.0,
                                    horizontalMargin: 46,
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
                                        label: Text('Product name'),
                                      ),
                                      DataColumn(
                                        label: Text('Your Price'),
                                      ),
                                      DataColumn(
                                        label: Text('Offered'),
                                      ),
                                      DataColumn(
                                        label: Text('Date created'),
                                      ),
                                      DataColumn(
                                        label: Text('Conditions'),
                                      ),
                                      DataColumn(
                                        label: Text('Time Left'),
                                      ),
                                      DataColumn(
                                        label: Text('Payment'),
                                      ),
                                      DataColumn(
                                        label: Text('Accept/Reject'),
                                      ),
                                    ],
                                    rows: rejectoffersViewer
                                        .map((e) => DataRow(cells: [
                                              DataCell(
                                                Row(
                                                  children: [
                                                    Checkbox(
                                                      value: e.selected,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(3),
                                                      ),
                                                      onChanged: (value) {
                                                        setState(() {
                                                          e.selected = value;
                                                          if (e.selected!) {
                                                            selected.add(e.id!);
                                                          } else {
                                                            selected.remove(e.id);
                                                          }
                                                        });
                                                      },
                                                    ),
                                                    SizedBox(width: 15),
                                                    Text(
                                                      e.lodgeName!,
                                                      style: TextStyle(
                                                        color: kUIDark,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              DataCell(
                                                Text(
                                                  'R${e.actualAmount}',
                                                  style: TextStyle(
                                                    color: kUIDark,
                                                  ),
                                                ),
                                              ),
                                              DataCell(
                                                Text(
                                                  'R${e.amount}',
                                                  style: TextStyle(
                                                    color: kPrimary1,
                                                  ),
                                                ),
                                              ),
                                              DataCell(
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    SizedBox(height: 20),
                                                    Text(
                                                      DateFormat('dd MM yyyy').format(e.date!.toDate()),
                                                      style: TextStyle(
                                                        color: kUIDark,
                                                      ),
                                                    ),
                                                    SizedBox(height: 8),
                                                    Text(
                                                      'At ${DateFormat('hh:mm a').format(e.date!.toDate())}',
                                                      style: TextStyle(
                                                        color: kUILight2,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              DataCell(
                                                Text(
                                                  e.deadLine!,
                                                  style: TextStyle(
                                                      color: e.deadLine == '24H'
                                                          ? kPrimary2
                                                          : e.deadLine == '48H'
                                                              ? kColorOrange
                                                              : e.deadLine == 'Flexible'
                                                                  ? kColorGreen
                                                                  : kUIDark),
                                                ),
                                              ),
                                              DataCell(
                                                SizedBox(
                                                  height: 90,
                                                  width: 90,
                                                  child: CountDownProgressIndicator(
                                                    controller: _controller,
                                                    timeTextStyle: TextStyle(
                                                      fontWeight: FontWeight.w300,
                                                      fontSize: 10,
                                                      color: kPrimary1,
                                                    ),
                                                    strokeWidth: 4,
                                                    valueColor: kPrimary1,
                                                    backgroundColor: kUILight,
                                                    initialPosition: 0,
                                                    duration: e.waiting!,
                                                    timeFormatter: (seconds) {
                                                      return Duration(seconds: seconds)
                                                          .toString()
                                                          .split('.')[0];
                                                    },
                                                    onComplete: () => null,
                                                  ),
                                                ),
                                              ),
                                              DataCell(
                                                Container(
                                                    decoration: BoxDecoration(
                                                        border: Border.all(
                                                            color: e.paid == 'Not Paid'
                                                                ? kPrimary2
                                                                : kPrimary1,
                                                            width: 1,
                                                            style: BorderStyle.solid),
                                                        borderRadius: BorderRadius.circular(20)),
                                                    width: 90,
                                                    height: 30,
                                                    child: SizedBox(
                                                        width: 50,
                                                        height: 30,
                                                        child: Center(
                                                          child: DropdownButton(
                                                              dropdownColor: Colors.white,
                                                              focusColor: Colors.white,
                                                              isDense: true,
                                                              value: e.paid,
                                                              borderRadius: BorderRadius.circular(20),
                                                              items: paymentStatus.map((String items) {
                                                                return DropdownMenuItem(
                                                                  value: items,
                                                                  child: Text(
                                                                    items,
                                                                    style: TextStyle(
                                                                      color: e.paid == 'Not Paid'
                                                                          ? kPrimary2
                                                                          : kPrimary1,
                                                                      fontSize: 12,
                                                                      fontWeight: FontWeight.w500,
                                                                    ),
                                                                  ),
                                                                );
                                                              }).toList(),
                                                              onChanged: (value) async {
                                                                setState(() {
                                                                  e.paid = value;
                                                                });
                                                                await FirebaseFirestore.instance
                                                                    .collection('offers')
                                                                    .doc(e.id)
                                                                    .update({'paid': e.paid});
                                                              }),
                                                        ))),
                                              ),
                                              DataCell(
                                                Transform.scale(
                                                  scale: 0.8,
                                                  child: CupertinoSwitch(
                                                    value: e.accepted!,
                                                    onChanged: (value) async {
                                                      setState(() {
                                                        e.accepted = value;
                                                        if (e.accepted!) {
                                                          status = 'accepted';
                                                        } else {
                                                          status = 'rejected';
                                                        }
                                                      });
                                                      await FirebaseFirestore.instance
                                                          .collection('offers')
                                                          .doc(e.id)
                                                          .update({'status': status});
                                                      getAllData();
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ]))
                                        .toList()),
                              ),
                        //pending offers tab
//starts here
/////////
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
                                    dataRowHeight: 90.0,
                                    horizontalMargin: 46,
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
                                        label: Text('Product name'),
                                      ),
                                      DataColumn(
                                        label: Text('Your Price'),
                                      ),
                                      DataColumn(
                                        label: Text('Offered'),
                                      ),
                                      DataColumn(
                                        label: Text('Date created'),
                                      ),
                                      DataColumn(
                                        label: Text('Conditions'),
                                      ),
                                      DataColumn(
                                        label: Text('Time Left'),
                                      ),
                                      DataColumn(
                                        label: Text('Payment'),
                                      ),
                                      DataColumn(
                                        label: Text('Accept/Reject'),
                                      ),
                                    ],
                                    rows: pendingoffersViewer
                                        .map((e) => DataRow(cells: [
                                              DataCell(
                                                Row(
                                                  children: [
                                                    Checkbox(
                                                      value: e.selected,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(3),
                                                      ),
                                                      onChanged: (value) {
                                                        setState(() {
                                                          e.selected = value;
                                                          if (e.selected!) {
                                                            selected.add(e.id!);
                                                          } else {
                                                            selected.remove(e.id);
                                                          }
                                                        });
                                                      },
                                                    ),
                                                    SizedBox(width: 15),
                                                    Text(
                                                      e.lodgeName!,
                                                      style: TextStyle(
                                                        color: kUIDark,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              DataCell(
                                                Text(
                                                  'R${e.actualAmount}',
                                                  style: TextStyle(
                                                    color: kUIDark,
                                                  ),
                                                ),
                                              ),
                                              DataCell(
                                                Text(
                                                  'R${e.amount}',
                                                  style: TextStyle(
                                                    color: kPrimary1,
                                                  ),
                                                ),
                                              ),
                                              DataCell(
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    SizedBox(height: 20),
                                                    Text(
                                                      DateFormat('dd MM yyyy').format(e.date!.toDate()),
                                                      style: TextStyle(
                                                        color: kUIDark,
                                                      ),
                                                    ),
                                                    SizedBox(height: 8),
                                                    Text(
                                                      'At ${DateFormat('hh:mm a').format(e.date!.toDate())}',
                                                      style: TextStyle(
                                                        color: kUILight2,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              DataCell(
                                                Text(
                                                  e.deadLine!,
                                                  style: TextStyle(
                                                      color: e.deadLine == '24H'
                                                          ? kPrimary2
                                                          : e.deadLine == '48H'
                                                              ? kColorOrange
                                                              : e.deadLine == 'Flexible'
                                                                  ? kColorGreen
                                                                  : kUIDark),
                                                ),
                                              ),
                                              DataCell(
                                                SizedBox(
                                                  height: 70,
                                                  width: 70,
                                                  child: CountDownProgressIndicator(
                                                    controller: _controller,
                                                    timeTextStyle: TextStyle(
                                                      fontWeight: FontWeight.w300,
                                                      fontSize: 10,
                                                      color: kPrimary1,
                                                    ),
                                                    strokeWidth: 4,
                                                    valueColor: kPrimary1,
                                                    backgroundColor: kUILight,
                                                    initialPosition: 0,
                                                    duration: e.waiting!,
                                                    timeFormatter: (seconds) {
                                                      return Duration(seconds: seconds)
                                                          .toString()
                                                          .split('.')[0];
                                                    },
                                                    onComplete: () => null,
                                                  ),
                                                ),
                                              ),
                                              DataCell(
                                                Container(
                                                    decoration: BoxDecoration(
                                                        border: Border.all(
                                                            color: e.paid == 'Not Paid'
                                                                ? kPrimary2
                                                                : kPrimary1,
                                                            width: 1,
                                                            style: BorderStyle.solid),
                                                        borderRadius: BorderRadius.circular(20)),
                                                    width: 90,
                                                    height: 30,
                                                    child: SizedBox(
                                                        width: 50,
                                                        height: 30,
                                                        child: Center(
                                                          child: DropdownButton(
                                                              dropdownColor: Colors.white,
                                                              focusColor: Colors.white,
                                                              isDense: true,
                                                              value: e.paid,
                                                              borderRadius: BorderRadius.circular(20),
                                                              items: paymentStatus.map((String items) {
                                                                return DropdownMenuItem(
                                                                  value: items,
                                                                  child: Text(
                                                                    items,
                                                                    style: TextStyle(
                                                                      color: e.paid == 'Not Paid'
                                                                          ? kPrimary2
                                                                          : kPrimary1,
                                                                      fontSize: 12,
                                                                      fontWeight: FontWeight.w500,
                                                                    ),
                                                                  ),
                                                                );
                                                              }).toList(),
                                                              onChanged: (value) async {
                                                                setState(() {
                                                                  e.paid = value;
                                                                });
                                                                await FirebaseFirestore.instance
                                                                    .collection('offers')
                                                                    .doc(e.id)
                                                                    .update({'paid': e.paid});
                                                              }),
                                                        ))),
                                              ),
                                              DataCell(
                                                Transform.scale(
                                                  scale: 0.8,
                                                  child: CupertinoSwitch(
                                                    value: e.accepted!,
                                                    onChanged: (value) async {
                                                      setState(() {
                                                        e.accepted = value;
                                                        if (e.accepted!) {
                                                          status = 'accepted';
                                                        } else {
                                                          status = 'rejected';
                                                        }
                                                      });
                                                      await FirebaseFirestore.instance
                                                          .collection('offers')
                                                          .doc(e.id)
                                                          .update({'status': status});
                                                      getAllData();
                                                    },
                                                  ),
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

  //getting all data

  Future getAllData() async {
    try {
      offersData.clear();
      offersViewer.clear();
      acceptedoffersViewer.clear();
      rejectoffersViewer.clear();
      pendingoffersViewer.clear();
      setState(() {
        isLoading = true;
      });

      QuerySnapshot snap =
          await FirebaseFirestore.instance.collection('compnies').where('id', isEqualTo: user.uid).get();
      setState(() {
        data = CompanyData.fromMap(snap.docs.first.data() as Map<String, dynamic>);
      });
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('offers')
          .where('compnyId', isEqualTo: user.uid)
          .where('date', isGreaterThan: Timestamp.fromDate(DateTime.now().subtract(Duration(days: 7))))
          .get();
      if (snapshot.docs.isNotEmpty) {
        setState(() {
          offersData =
              snapshot.docs.map((e) => OffersData.fromMap(e.data() as Map<String, dynamic>)).toList();
        });
      }
      for (var i in offersData) {
        QuerySnapshot lodgeSnap = await FirebaseFirestore.instance
            .collection('lodges')
            .where('id', isEqualTo: i.lodgeid)
            .get();
        LodgeData ldata = LodgeData.fromMap(lodgeSnap.docs.first.data() as Map<String, dynamic>);
        setState(() {
          offersViewer.add(
            OfferViewerData(
                amount: double.parse(i.amount!.toString()),
                companyid: i.companyid,
                deadLine: i.deadLine,
                from: i.from,
                id: i.id,
                lodgeid: i.lodgeid,
                persons: int.parse(i.persons!.toString()),
                status: i.status,
                to: i.to,
                userid: i.userid,
                dateCreated: i.dateCreated,
                date: i.date,
                actualAmount: double.parse(i.actualAmount!.toString()),
                paid: i.paid,
                lodgeName: ldata.name,
                selected: false,
                accepted: i.status == 'accepted' ? true : false,
                waiting: calculateDeadLine(i.deadLine!, i.date!.toDate(), i.from!.toDate())),
          );
          if (!lodgeNames.contains(ldata.name!)) {
            lodgeNames.add(ldata.name!);
          }
        });
      }
      //gettin pendigs, accepted,rejected
      temp = offersViewer;
      acceptedoffersViewer = offersViewer.where((element) => element.status == 'accepted').toList();
      rejectoffersViewer = offersViewer.where((element) => element.status == 'rejected').toList();
      pendingoffersViewer = offersViewer.where((element) => element.status == 'pending').toList();
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

  //getting all data by search

  getAllDatabyName(String lodgeName) {
    try {
      setState(() {
        offersViewer = temp.where((element) => element.lodgeName == lodgeName).toList();
        //gettin pendigs, accepted,rejected

        acceptedoffersViewer = offersViewer.where((element) => element.status == 'accepted').toList();
        rejectoffersViewer = offersViewer.where((element) => element.status == 'rejected').toList();
        pendingoffersViewer = offersViewer.where((element) => element.status == 'pending').toList();
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

  //getting all data when search is empty

  Future getAllDatabyAll() async {
    offersViewer.clear();
    acceptedoffersViewer.clear();
    rejectoffersViewer.clear();
    pendingoffersViewer.clear();
    try {
      setState(() {
        offersViewer = temp;
        //gettin pendigs, accepted,rejected

        acceptedoffersViewer = offersViewer.where((element) => element.status == 'accepted').toList();
        rejectoffersViewer = offersViewer.where((element) => element.status == 'rejected').toList();
        pendingoffersViewer = offersViewer.where((element) => element.status == 'pending').toList();
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

  //calculate seconds
  int calculateDeadLine(String period, DateTime dateCreated, DateTime from) {
    if (period == '24H') {
      int wait = dateCreated.add(Duration(hours: 24)).difference(DateTime.now()).inSeconds;
      return wait < 0 ? 1 : wait;
    } else if (period == '48H') {
      int wait = dateCreated.add(Duration(hours: 48)).difference(DateTime.now()).inSeconds;
      return wait < 0 ? 1 : wait;
    } else {
      int wait = from.subtract(Duration(days: 1)).difference(dateCreated).inSeconds;

      return wait < 0 ? 1 : wait;
    }
  }

  //getting data by selected days
  Future getDataByDays(String? value) async {
    try {
      DateTime searchDate = DateTime.now(); //'', '', 'Past 90 days'
      if (value == 'Past 7 days') {
        setState(() {
          searchDate = DateTime.now().subtract(Duration(days: 8));
        });
      } else if (value == 'Past 30 days') {
        setState(() {
          searchDate = DateTime.now().subtract(Duration(days: 31));
        });
      } else {
        setState(() {
          searchDate = DateTime.now().subtract(Duration(days: 91));
        });
      }
      offersData.clear();
      offersViewer.clear();
      acceptedoffersViewer.clear();
      rejectoffersViewer.clear();
      pendingoffersViewer.clear();
      setState(() {
        isLoading = true;
      });
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('offers')
          .where('compnyId', isEqualTo: user.uid)
          .where('date', isGreaterThan: Timestamp.fromDate(searchDate))
          .get();
      if (snapshot.docs.isNotEmpty) {
        setState(() {
          offersData =
              snapshot.docs.map((e) => OffersData.fromMap(e.data() as Map<String, dynamic>)).toList();
        });
      }
      for (var i in offersData) {
        QuerySnapshot lodgeSnap = await FirebaseFirestore.instance
            .collection('lodges')
            .where('id', isEqualTo: i.lodgeid)
            .get();
        LodgeData ldata = LodgeData.fromMap(lodgeSnap.docs.first.data() as Map<String, dynamic>);
        setState(() {
          offersViewer.add(
            OfferViewerData(
                amount: double.parse(i.amount!.toString()),
                companyid: i.companyid,
                deadLine: i.deadLine,
                from: i.from,
                id: i.id,
                lodgeid: i.lodgeid,
                persons: int.parse(i.persons!.toString()),
                status: i.status,
                to: i.to,
                userid: i.userid,
                dateCreated: i.dateCreated,
                date: i.date,
                actualAmount: double.parse(i.actualAmount!.toString()),
                paid: i.paid,
                lodgeName: ldata.name,
                selected: false,
                accepted: i.status == 'accepted' ? true : false,
                waiting: calculateDeadLine(i.deadLine!, i.date!.toDate(), i.from!.toDate())),
          );
          if (!lodgeNames.contains(ldata.name!)) {
            lodgeNames.add(ldata.name!);
          }
        });
      }
      //gettin pendigs, accepted,rejected
      temp = offersViewer;
      acceptedoffersViewer = offersViewer.where((element) => element.status == 'accepted').toList();
      rejectoffersViewer = offersViewer.where((element) => element.status == 'rejected').toList();
      pendingoffersViewer = offersViewer.where((element) => element.status == 'pending').toList();
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

  //getting data by date range

  Future getDataByDates(DateTime stDate, DateTime edDate) async {
    try {
      offersData.clear();
      offersViewer.clear();
      acceptedoffersViewer.clear();
      rejectoffersViewer.clear();
      pendingoffersViewer.clear();
      setState(() {
        isLoading = true;
      });
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('offers')
          .where('compnyId', isEqualTo: user.uid)
          .where('date', isGreaterThan: Timestamp.fromDate(stDate.subtract(Duration(days: 1))))
          .get();
      if (snapshot.docs.isNotEmpty) {
        setState(() {
          offersData =
              snapshot.docs.map((e) => OffersData.fromMap(e.data() as Map<String, dynamic>)).toList();
          offersData = offersData
              .where((element) => element.date!.toDate().isBefore(edDate.add(Duration(days: 1))))
              .toList();
        });
      }
      for (var i in offersData) {
        QuerySnapshot lodgeSnap = await FirebaseFirestore.instance
            .collection('lodges')
            .where('id', isEqualTo: i.lodgeid)
            .get();
        LodgeData ldata = LodgeData.fromMap(lodgeSnap.docs.first.data() as Map<String, dynamic>);
        setState(() {
          offersViewer.add(
            OfferViewerData(
                amount: double.parse(i.amount!.toString()),
                companyid: i.companyid,
                deadLine: i.deadLine,
                from: i.from,
                id: i.id,
                lodgeid: i.lodgeid,
                persons: int.parse(i.persons!.toString()),
                status: i.status,
                to: i.to,
                userid: i.userid,
                dateCreated: i.dateCreated,
                date: i.date,
                actualAmount: double.parse(i.actualAmount!.toString()),
                paid: i.paid,
                lodgeName: ldata.name,
                selected: false,
                accepted: i.status == 'accepted' ? true : false,
                waiting: calculateDeadLine(i.deadLine!, i.date!.toDate(), i.from!.toDate())),
          );
          if (!lodgeNames.contains(ldata.name!)) {
            lodgeNames.add(ldata.name!);
          }
        });
      }
      //gettin pendigs, accepted,rejected
      temp = offersViewer;
      acceptedoffersViewer = offersViewer.where((element) => element.status == 'accepted').toList();
      rejectoffersViewer = offersViewer.where((element) => element.status == 'rejected').toList();
      pendingoffersViewer = offersViewer.where((element) => element.status == 'pending').toList();
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

  //showing date picker for selecting range

  showDatePickerDialogue() async {
    showDialog(
        context: context,
        builder: (context) => StatefulBuilder(
            builder: (context, setState) => AlertDialog(
                  content: Container(
                    width: 600,
                    height: 500,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(20.0)),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          SizedBox(
                            height: 400,
                            width: 590,
                            child: SfDateRangePicker(
                              selectionMode: DateRangePickerSelectionMode.range,
                              enableMultiView: true,
                              viewSpacing: 20,
                              headerStyle: DateRangePickerHeaderStyle(
                                textAlign: TextAlign.center,
                              ),
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
                            height: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(color: kPrimary1),
                                ),
                              ),
                              const SizedBox(
                                width: 50,
                              ),
                              InkWell(
                                onTap: () {
                                  getDataByDates(startDate, endDate);
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  'Ok',
                                  style: TextStyle(color: kPrimary1),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                )));
  }
}
