// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fianl_offer_dashboard/models/ammentites.dart';
import 'package:fianl_offer_dashboard/models/lodge.dart';
import 'package:fianl_offer_dashboard/models/region.dart';
import 'package:fianl_offer_dashboard/widgets/button.dart';
import 'package:fianl_offer_dashboard/widgets/side_bar.dart';
import 'package:fianl_offer_dashboard/widgets/text_field.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:intl/intl.dart';
import '../constants.dart';
import '../models/category.dart';
import '../models/company.dart';
import '../widgets/error.dart';
import 'package:http/http.dart' as http;

class NewProduct extends StatefulWidget {
  const NewProduct({Key? key}) : super(key: key);

  @override
  State<NewProduct> createState() => _NewProductState();
}

class _NewProductState extends State<NewProduct> {
  final userID = FirebaseAuth.instance.currentUser!.uid;
  //google places data

  TextEditingController name = TextEditingController();
  TextEditingController video = TextEditingController();
  TextEditingController description = TextEditingController();
  TextEditingController address = TextEditingController();
  TextEditingController priceC = TextEditingController();
  TextEditingController terms = TextEditingController();
  TextEditingController lat = TextEditingController();
  TextEditingController long = TextEditingController();
  final form = GlobalKey<FormState>();
  List<XFile> imgs = [];
  bool permanant = false;
  DateTime from = DateTime.now();
  DateTime to = DateTime.now().add(Duration(days: 30));
  List<String> regions = [];
  String selectedValue = '';
  String selectUni1 = '';
  String selectUni2 = '';
  List<AmentitesData> amentitesData = [];
  //List ammentitiesIncluded = [];
  List<String> apiAddress = [];
  List<String> categories = [];
  final user = FirebaseAuth.instance.currentUser!;
  bool isLoading = false;
  CompanyData? data;
  List<String> amentitiesincluded = ['Pet Frinedly', 'Cell Reception', 'Wifi'];
  List<String> unit1 = ['Per Person', 'Per Couple'];
  List<String> unit2 = ['Per Night', 'Per Day', 'Per Week'];
  CategoryData? catData;
  String category = '';
  @override
  void initState() {
    getData();
    selectUni1 = unit1[0];
    selectUni2 = unit2[0];

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: kColorWhite,
          elevation: 0,
          title: const Text(
            'Add New Product',
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
                  width: 150,
                  height: 150,
                  child: Row(
                    children: [
                      LoadingIndicator(
                        indicatorType: Indicator.orbit,
                        colors: [Colors.red, Colors.blue],
                      ),
                    ],
                  ),
                ),
              )
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(left: 25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 21),
                      Container(
                        width: 875.77,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(width: 1, color: kFormStockColor),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 22),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 15),
                              Text(
                                'Product Name',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                  color: kUIDark,
                                ),
                              ),
                              SizedBox(height: 10),
                              SizedBox(
                                width: 398,
                                height: 49,
                                child: TextFieldWidget(
                                  hintText: '',
                                  ebColor: kFormStockColor,
                                  controller: name,
                                ),
                              ),
                              SizedBox(height: 17),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Add photos',
                                    style: TextStyle(
                                        fontSize: 20, fontWeight: FontWeight.w500, color: kUIDark),
                                  ),
                                ],
                              ),
                              SizedBox(height: 22),
                              Text(
                                'Photos help other people trust you',
                                style: TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.w400, color: kUILight2),
                              ),
                              SizedBox(height: 17),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: SizedBox(
                                      height: 250.66,
                                      width: 450,
                                      child: ListView.builder(
                                          itemCount: imgs.isEmpty ? 0 : imgs.length,
                                          shrinkWrap: true,
                                          primary: true,
                                          itemBuilder: (context, index) {
                                            return Container(
                                                height: 230,
                                                width: 420,
                                                margin: EdgeInsets.all(8.0),
                                                child: Stack(
                                                  children: [
                                                    Image.network(
                                                      imgs[index].path,
                                                      height: 230,
                                                      width: 420,
                                                    ),
                                                    Positioned(
                                                        bottom: 2,
                                                        right: 2,
                                                        child: IconButton(
                                                            onPressed: () {
                                                              setState(() {
                                                                imgs.removeAt(index);
                                                              });
                                                            },
                                                            icon: Icon(
                                                              Icons.delete,
                                                              color: Colors.red,
                                                            ))),
                                                  ],
                                                ));
                                          }),
                                    ),
                                  ),
                                  SizedBox(width: 22),
                                  InkWell(
                                    onTap: () {
                                      pickImage();
                                    },
                                    child: DottedBorder(
                                      borderType: BorderType.RRect,
                                      radius: Radius.circular(8),
                                      color: kPrimary2,
                                      dashPattern: [7, 7, 7, 7],
                                      child: SizedBox(
                                        width: 191.72,
                                        height: 103.66,
                                        child: Center(
                                          child: Container(
                                            width: 40,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(width: 1, color: kPrimary2),
                                            ),
                                            child: Center(
                                              child: Icon(
                                                CupertinoIcons.add,
                                                color: kPrimary2,
                                                size: 25,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              SizedBox(height: 20),
                              Wrap(
                                children: [
                                  Text(
                                    'Video URL',
                                    style: TextStyle(
                                        fontSize: 12, fontWeight: FontWeight.w500, color: kUIDark),
                                  ),
                                  Text(
                                    '   (Optional)',
                                    style: TextStyle(
                                        fontSize: 12, fontWeight: FontWeight.w400, color: kUILight2),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              SizedBox(
                                width: 398,
                                height: 49,
                                child: TextFieldWidget(
                                  hintText: '',
                                  ebColor: kFormStockColor,
                                  controller: video,
                                ),
                              ),
                              SizedBox(height: 20),
                              Text(
                                'Description',
                                style:
                                    TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: kUIDark),
                              ),
                              SizedBox(height: 10),
                              SizedBox(
                                width: 398,
                                child: TextField(
                                  controller: description,
                                  maxLines: 4,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: kUILight2,
                                  ),
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5),
                                      borderSide: BorderSide(color: kUILight, width: 1),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5),
                                      borderSide: BorderSide(color: kFormStockColor, width: 1),
                                    ),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                                    hintStyle: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: kUILight2,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 20),
                              Text(
                                'Amenities Include',
                                style:
                                    TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: kUIDark),
                              ),
                              SizedBox(height: 10),
                              SizedBox(
                                  width: 221,
                                  height: 41,
                                  child: Container(
                                    padding: EdgeInsets.all(5.0),
                                    decoration: BoxDecoration(
                                        border:
                                            Border.all(color: kFormStockColor, style: BorderStyle.solid),
                                        borderRadius: BorderRadius.circular(5)),
                                    width: 175,
                                    height: 30,
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton(
                                          icon: Icon(Icons.arrow_downward),
                                          hint: Text('  --Please Select--'),
                                          dropdownColor: Colors.white,
                                          focusColor: Colors.white,
                                          isDense: true,
                                          items: amentitiesincluded.map((String items) {
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
                                            List val =
                                                amentitesData.where((e) => e.item! == value!).toList();
                                            if (val.isEmpty) {
                                              setState(() {
                                                amentitesData
                                                    .add(AmentitesData(item: value, present: true));
                                              });
                                            }
                                          }),
                                    ),
                                  )),
                              SizedBox(height: 30),
                              SizedBox(
                                height: 40,
                                child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    shrinkWrap: true,
                                    primary: false,
                                    itemCount: amentitesData.isEmpty ? 0 : amentitesData.length,
                                    //ammentitiesIncluded.isEmpty ? 0 : ammentitiesIncluded.length,
                                    itemBuilder: (context, index) {
                                      return addAmmentites(amentitesData[index], index);
                                    }),
                              ),
                              SizedBox(height: 60),
                              Text(
                                'Product Live Dates',
                                style:
                                    TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: kUIDark),
                              ),
                              SizedBox(height: 17),
                              Row(
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Date From',
                                        style: TextStyle(
                                            fontSize: 12, fontWeight: FontWeight.w500, color: kUIDark),
                                      ),
                                      SizedBox(height: 10),
                                      Container(
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: kFormStockColor, style: BorderStyle.solid),
                                              borderRadius: BorderRadius.circular(5)),
                                          width: 261,
                                          height: 49,
                                          child: InkWell(
                                            onTap: () async {
                                              final picked = await showDatePicker(
                                                  context: context,
                                                  initialDate: DateTime.now(),
                                                  firstDate: DateTime.now(),
                                                  lastDate: DateTime(2099));
                                              if (picked != null) {
                                                setState(() {
                                                  from = picked;
                                                });
                                              }
                                            },
                                            child: Padding(
                                              padding: EdgeInsets.only(
                                                  left: 10.0, right: 8.0, top: 5.0, bottom: 5.0),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text(DateFormat('MM/dd/yyyy').format(from)),
                                                  Icon(
                                                    CupertinoIcons.arrow_down,
                                                    color: kUILight6,
                                                    size: 15,
                                                  )
                                                ],
                                              ),
                                            ),
                                          )),
                                    ],
                                  ),
                                  SizedBox(width: 20),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Date To',
                                        style: TextStyle(
                                            fontSize: 12, fontWeight: FontWeight.w500, color: kUIDark),
                                      ),
                                      SizedBox(height: 10),
                                      Container(
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: kFormStockColor, style: BorderStyle.solid),
                                              borderRadius: BorderRadius.circular(5)),
                                          width: 261,
                                          height: 49,
                                          child: InkWell(
                                            onTap: () async {
                                              final picked = await showDatePicker(
                                                  context: context,
                                                  initialDate: DateTime.now(),
                                                  firstDate: DateTime.now(),
                                                  lastDate: DateTime(2099));
                                              if (picked != null) {
                                                setState(() {
                                                  to = picked;
                                                });
                                              }
                                            },
                                            child: Padding(
                                              padding: EdgeInsets.only(
                                                  left: 10.0, right: 8.0, top: 5.0, bottom: 5.0),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text(DateFormat('MM/dd/yyyy').format(to)),
                                                  Icon(
                                                    CupertinoIcons.arrow_down,
                                                    color: kUILight6,
                                                    size: 15,
                                                  )
                                                ],
                                              ),
                                            ),
                                          )),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(height: 17),
                              Row(
                                children: [
                                  Checkbox(
                                    value: permanant,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        permanant = value!;
                                      });
                                    },
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    'Permanent',
                                    style: TextStyle(
                                        fontSize: 16, fontWeight: FontWeight.w500, color: kUIDark),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 32.62),
                      Container(
                        width: 875.77,
                        decoration: BoxDecoration(
                          border: Border.all(width: 1, color: kFormStockColor),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 25),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 25),
                              Form(
                                key: form,
                                child: Row(
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Region',
                                          style: TextStyle(
                                              fontSize: 12, fontWeight: FontWeight.w500, color: kUIDark),
                                        ),
                                        SizedBox(height: 10),
                                        SizedBox(
                                            width: 221,
                                            height: 43,
                                            child: Container(
                                              padding: EdgeInsets.all(5.0),
                                              decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: kFormStockColor, style: BorderStyle.solid),
                                                  borderRadius: BorderRadius.circular(5)),
                                              width: 120,
                                              height: 30,
                                              child: DropdownButtonHideUnderline(
                                                child: DropdownButton(
                                                    icon: Icon(Icons.arrow_downward),
                                                    hint: Text('  --Please Select--'),
                                                    value: selectedValue,
                                                    dropdownColor: Colors.white,
                                                    focusColor: Colors.white,
                                                    isDense: true,
                                                    items: regions.map((String items) {
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
                                                        selectedValue = value!;
                                                      });
                                                    }),
                                              ),
                                            )),
                                      ],
                                    ),
                                    SizedBox(width: 20),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Address',
                                          style: TextStyle(
                                              fontSize: 12, fontWeight: FontWeight.w500, color: kUIDark),
                                        ),
                                        SizedBox(height: 10),
                                        SizedBox(
                                            width: 250,
                                            height: 43,
                                            child: TypeAheadFormField(
                                              suggestionsCallback: (patteren) => apiAddress.where(
                                                  (element) => element
                                                      .toLowerCase()
                                                      .contains(patteren.toLowerCase())),
                                              onSuggestionSelected: (String value) {
                                                address.text = value;
                                                getLatLong(value);
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
                                                  // prefixIcon: Icon(
                                                  //   CupertinoIcons.search,
                                                  //   size: 17,
                                                  // ),
                                                  // suffixIcon: Icon(
                                                  //   CupertinoIcons.mic_fill,
                                                  //   size: 17,
                                                  // ),
                                                  //hintText: 'Search',
                                                  border: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(10),
                                                    borderSide: BorderSide(color: kUILight, width: 1),
                                                  ),
                                                  enabledBorder: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(10),
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
                                                controller: address,
                                                onChanged: ((value) {
                                                  if (value != '') {
                                                    //apiAddress.clear();
                                                    getAddress(value);
                                                  }
                                                }),
                                                onSubmitted: (value) {
                                                  getLatLong(value);
                                                },
                                              ),
                                            )),
                                      ],
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Latitude',
                                          style: TextStyle(
                                              fontSize: 12, fontWeight: FontWeight.w500, color: kUIDark),
                                        ),
                                        SizedBox(height: 10),
                                        SizedBox(
                                            width: 120,
                                            height: 43,
                                            child: TextFieldWidget(
                                              hintText: '',
                                              ebColor: kFormStockColor,
                                              errorTxt: 'enter Latitude',
                                              validate: true,
                                              controller: lat,
                                            )),
                                      ],
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Longitude',
                                          style: TextStyle(
                                              fontSize: 12, fontWeight: FontWeight.w500, color: kUIDark),
                                        ),
                                        SizedBox(height: 10),
                                        SizedBox(
                                            width: 120,
                                            height: 43,
                                            child: TextFieldWidget(
                                              hintText: '',
                                              ebColor: kFormStockColor,
                                              errorTxt: 'enter Longitude',
                                              validate: true,
                                              controller: long,
                                            )),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 20),
                              Text(
                                'Unit of measure',
                                style:
                                    TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: kUIDark),
                              ),
                              SizedBox(height: 10),
                              Row(
                                children: [
                                  SizedBox(
                                    width: 120,
                                    height: 40,
                                    child: Container(
                                      padding: EdgeInsets.all(10.0),
                                      decoration: BoxDecoration(
                                          border: Border.all(color: kPrimary1, style: BorderStyle.solid),
                                          borderRadius: BorderRadius.circular(20)),
                                      width: 70,
                                      height: 40,
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton(
                                            hint: Text('----'),
                                            value: selectUni1,
                                            icon: Icon(Icons.arrow_drop_down),
                                            dropdownColor: Colors.white,
                                            focusColor: Colors.white,
                                            isDense: true,
                                            items: unit1.map((String items) {
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
                                                selectUni1 = value!;
                                              });
                                            }),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 9),
                                  SizedBox(
                                    width: 120,
                                    height: 40,
                                    child: Container(
                                      padding: EdgeInsets.all(10.0),
                                      decoration: BoxDecoration(
                                          border: Border.all(color: kPrimary1, style: BorderStyle.solid),
                                          borderRadius: BorderRadius.circular(20)),
                                      width: 70,
                                      height: 40,
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton(
                                            hint: Text('----'),
                                            value: selectUni2,
                                            icon: Icon(Icons.arrow_drop_down),
                                            dropdownColor: Colors.white,
                                            focusColor: Colors.white,
                                            isDense: true,
                                            items: unit2.map((String items) {
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
                                                selectUni2 = value!;
                                              });
                                            }),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Category',
                                        style: TextStyle(
                                            fontSize: 12, fontWeight: FontWeight.w500, color: kUIDark),
                                      ),
                                      SizedBox(height: 10),
                                      SizedBox(
                                          width: 221,
                                          height: 43,
                                          child: Container(
                                            padding: EdgeInsets.all(5.0),
                                            decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: kFormStockColor, style: BorderStyle.solid),
                                                borderRadius: BorderRadius.circular(5)),
                                            width: 120,
                                            height: 30,
                                            child: DropdownButtonHideUnderline(
                                              child: DropdownButton(
                                                  icon: Icon(Icons.arrow_downward),
                                                  hint: Text('  --Please Select--'),
                                                  value: category,
                                                  dropdownColor: Colors.white,
                                                  focusColor: Colors.white,
                                                  isDense: true,
                                                  items: categories.map((String items) {
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
                                                      category = value!;
                                                    });
                                                  }),
                                            ),
                                          )),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(height: 20),
                              Text(
                                'Normal price(R)',
                                style:
                                    TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: kUIDark),
                              ),
                              SizedBox(height: 10),
                              SizedBox(
                                width: 221,
                                height: 43,
                                child: TextFieldWidget(
                                  hintText: '',
                                  ebColor: kFormStockColor,
                                  controller: priceC,
                                ),
                              ),
                              SizedBox(height: 20),
                              Text(
                                'Terms',
                                style:
                                    TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: kUIDark),
                              ),
                              SizedBox(height: 10),
                              SizedBox(
                                width: 398,
                                child: TextField(
                                  controller: terms,
                                  maxLines: 4,
                                  style: TextStyle(
                                      fontSize: 14, fontWeight: FontWeight.w400, color: kUILight2),
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5),
                                      borderSide: BorderSide(color: kUILight, width: 1),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5),
                                      borderSide: BorderSide(color: kFormStockColor, width: 1),
                                    ),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                                    hintStyle: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: kUILight2,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 41),
                      SizedBox(
                        width: 800,
                        child: Center(
                          child: FixedPrimary(
                              buttonText: 'Save Changes',
                              ontap: () {
                                if (name.text.isEmpty) {
                                  showMsgonSave('Enter name', context);
                                } else if (imgs.length < 3) {
                                  showMsgonSave('select 03 images', context);
                                } else if (description.text.isEmpty) {
                                  showMsgonSave('Enter description', context);
                                } else if (address.text.isEmpty) {
                                  showMsgonSave('Enter address', context);
                                } else if (priceC.text.isEmpty) {
                                  showMsgonSave('Enter price', context);
                                } else if (terms.text.isEmpty) {
                                  showMsgonSave('Enter terms', context);
                                } else {
                                  savingLodge();
                                }
                              }),
                        ),
                      ),
                      SizedBox(height: 116),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  //getting data

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
      QuerySnapshot regionsnap =
          await FirebaseFirestore.instance.collection('region').where('active', isEqualTo: true).get();

      if (regionsnap.docs.isNotEmpty) {
        List<RegionData> regionData =
            regionsnap.docs.map((e) => RegionData.fromMap(e.data() as Map<String, dynamic>)).toList();
        setState(() {
          regions = regionData.map((e) => e.region!).toList();
          selectedValue = regions[0];
        });
      }
      QuerySnapshot catsnap = await FirebaseFirestore.instance
          .collection('categories')
          .where('companyid', isEqualTo: user.uid)
          .get();
      if (catsnap.docs.isNotEmpty) {
        setState(() {
          catData = CategoryData.fromMap(catsnap.docs.first.data() as Map<String, dynamic>);
          for (var i in catData!.category!) {
            categories.add(i);
          }
          category = categories[0];
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
      setState(() {
        isLoading = false;
      });
    }
  }

  // ammentites widget
  Widget addAmmentites(AmentitesData data, int index) {
    return Container(
      margin: EdgeInsets.only(left: 10.0),
      padding: EdgeInsets.only(left: 5.0, right: 5.0),
      height: 40,
      //width: 150,
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(style: BorderStyle.solid, color: kPrimary1),
          borderRadius: BorderRadius.circular(20.0)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            data.item!,
            style: const TextStyle(color: kPrimary1),
          ),
          InkWell(
            onTap: () {
              setState(() {
                amentitesData.removeAt(index);
              });
            },
            child: const Icon(
              Icons.close,
              color: kPrimary1,
            ),
          )
        ],
      ),
    );
  }

//picking image
  Future pickImage() async {
    // ignore: invalid_use_of_visible_for_testing_member
    final imageweb = await ImagePicker.platform.getMultiImage();
    if (imageweb != null) {
      setState(() {
        imgs.addAll(imageweb);
      });
    }
  }

  //getting autocomplete address address
  Future getAddress(String value) async {
    try {
      final response = await http.get(
        Uri.parse(
            '$baseUrl/https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$value&key=$apiKey'),
      );

      if (response.statusCode == 200) {
        var temp = jsonDecode(response.body)['predictions'];
        setState(() {
          for (var i in temp) {
            apiAddress.add(i['description']);
          }
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
      setState(() {});
    }
  }

  //getting latitude and longtiude from address
  Future getLatLong(String address) async {
    try {
      final response = await http.get(
          Uri.parse('https://maps.googleapis.com/maps/api/geocode/json?address=$address&key=$apiKey'),
          headers: {"Access-Control-Allow-Origin": "*"});

      if (response.statusCode == 200) {
        var temp = jsonDecode(response.body)['results'];
        for (var element in temp) {
          Map obj = element;
          Map geo = obj['geometry'];
          Map loc = geo['location'];
          setState(() {
            lat = loc['lat'];
            long = loc['lng'];
          });
        }
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
      setState(() {});
    }
  }

  //saving new lodge

  Future savingLodge() async {
    setState(() {
      isLoading = true;
    });
    try {
      if (form.currentState!.validate()) {
        final newLodge = FirebaseFirestore.instance.collection('lodges').doc();
        //uploading Images
        List imgUrls = [];
        for (var i in imgs) {
          final firebaseStorage = FirebaseStorage.instance;
          var snapshot =
              await firebaseStorage.ref().child('/lodge_images/${newLodge.id}${i.name}').putData(
                    await i.readAsBytes(),
                    SettableMetadata(contentType: 'image/jpeg'),
                  );
          var imgUrlNew = await snapshot.ref.getDownloadURL();
          setState(() {
            imgUrls.add(imgUrlNew);
          });
        }

        List cell = amentitesData.where((element) => element.item! == 'Cell Reception').toList();
        List pet = amentitesData.where((element) => element.item! == 'Pet Friendly').toList();
        List wifi = amentitesData.where((element) => element.item! == 'Wifi').toList();
        Map<String, dynamic> amenTities = {
          'Cell Reception': cell.isEmpty ? false : true,
          'Wifi': wifi.isEmpty ? false : true,
          'Pet Friendly': pet.isEmpty ? false : true
        };
        LodgeData data = LodgeData(
            amentities: amenTities,
            companyId: userID,
            description: description.text,
            duration: selectUni2,
            from: Timestamp.fromDate(from),
            id: newLodge.id,
            location: address.text,
            name: name.text,
            permanent: permanant,
            unit: selectUni1,
            photos: imgUrls,
            price: double.parse(priceC.text),
            region: selectedValue,
            terms: terms.text,
            to: Timestamp.fromDate(to),
            videoUrl: video.text,
            bookings: 0,
            ranking: 0,
            reviews: 0,
            latitude: double.parse(lat.text),
            longitude: double.parse(long.text),
            date: Timestamp.fromDate(DateTime.now()),
            status: 'pending',
            category: category,
            dateCreated: DateFormat('yyyy-MM-dd').format(DateTime.now()),
            adminStatus: 'Pending',
            archive: false);

        await newLodge.set(data.toMap()).whenComplete(() {
          setState(() {
            isLoading = false;
          });
        }).then((value) => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ErrorDialog(
                    title: 'Succes',
                    message: 'Your product is saved successfully',
                    type: 'E',
                    function: () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SideBar(
                                    page: 2,
                                  )));
                    },
                    buttontxt: 'Close'))));
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
}
