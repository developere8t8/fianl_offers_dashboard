// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fianl_offer_dashboard/constants.dart';
import 'package:fianl_offer_dashboard/models/admin_category.dart';
import 'package:fianl_offer_dashboard/models/category.dart';
import 'package:fianl_offer_dashboard/widgets/button.dart';
import 'package:fianl_offer_dashboard/widgets/error.dart';
import 'package:fianl_offer_dashboard/widgets/text_field.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'dart:js' as js;
import '../models/ammentites.dart';
import '../models/company.dart';

class ProfileSettings extends StatefulWidget {
  const ProfileSettings({Key? key}) : super(key: key);

  @override
  State<ProfileSettings> createState() => _ProfileSettingsState();
}

class _ProfileSettingsState extends State<ProfileSettings> {
  final user = FirebaseAuth.instance.currentUser!;
  TextEditingController newEmail = TextEditingController();
  TextEditingController address = TextEditingController();
  TextEditingController city = TextEditingController();
  TextEditingController regNumber = TextEditingController();
  TextEditingController vat = TextEditingController();
  TextEditingController adminName = TextEditingController();
  TextEditingController fbLink = TextEditingController();
  TextEditingController instaLink = TextEditingController();
  TextEditingController webLink = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController phone = TextEditingController();
  final key = GlobalKey<FormState>();

  bool isLoading = false;
  CompanyData? data;
  List<String> categories = []; //for all categories names
  CategoryData? companyCategories; //for company categoeies data
  List<String> selectedCategorise = []; //for selected categories names
  List<AdminCategoryData> catData = []; //for all categories added by admin
  XFile? img;

  @override
  void initState() {
    getData();
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
            'Profile Settings',
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
                    child: Form(
                      key: key,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 21,
                          ),
                          Container(
                            width: 870,
                            //height: 587.38,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(width: 1, color: kFormStockColor),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 22),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 20),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Your photo',
                                        style: TextStyle(
                                            fontSize: 20, fontWeight: FontWeight.w500, color: kUIDark),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 17),
                                  Text(
                                    'Photos help you other people trust',
                                    style: TextStyle(
                                        fontSize: 12, fontWeight: FontWeight.w400, color: kUILight2),
                                  ),
                                  SizedBox(height: 17),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(10), color: kPrimary1),
                                        child: img != null
                                            ? CircleAvatar(
                                                backgroundColor: Colors.white,
                                                radius: 100,
                                                backgroundImage: NetworkImage(
                                                  img!.path,
                                                ),
                                              )
                                            : CircleAvatar(
                                                backgroundColor: Colors.white,
                                                radius: 100,
                                                backgroundImage: NetworkImage(data!.imgUrl!),
                                              ),
                                      ),
                                      SizedBox(width: 22),
                                      DottedBorder(
                                        borderType: BorderType.RRect,
                                        radius: Radius.circular(8),
                                        color: kPrimary2,
                                        dashPattern: [7, 7, 7, 7],
                                        child: SizedBox(
                                          width: 191.72,
                                          height: 103.66,
                                          child: Center(
                                              child: InkWell(
                                            onTap: () {
                                              pickImage();
                                            },
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
                                          )),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 20),
                                  Text(
                                    'Select Your Categories',
                                    style: TextStyle(
                                        fontSize: 12, fontWeight: FontWeight.w500, color: kUIDark),
                                  ),
                                  SizedBox(height: 10),
                                  SizedBox(
                                      width: 360,
                                      height: 49,
                                      child: Container(
                                        padding: EdgeInsets.all(5.0),
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                color: kFormStockColor, style: BorderStyle.solid),
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
                                                if (!selectedCategorise.contains(value)) {
                                                  setState(() {
                                                    selectedCategorise.add(value!);
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
                                        itemCount:
                                            selectedCategorise.isEmpty ? 0 : selectedCategorise.length,
                                        itemBuilder: (context, index) {
                                          return addNewCategory(selectedCategorise[index], index);
                                        }),
                                  ),
                                  SizedBox(height: 10),
                                  SizedBox(
                                      width: 150,
                                      height: 43,
                                      child: Center(
                                        child: FixedPrimary(
                                            buttonText: 'Save Category',
                                            ontap: () async {
                                              saveCategory();
                                            }),
                                      )),
                                  SizedBox(height: 52),
                                  Row(
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Email',
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                color: kUIDark),
                                          ),
                                          SizedBox(height: 10),
                                          SizedBox(
                                              width: 221,
                                              height: 43,
                                              child: TextFieldWidget(
                                                hintText: '',
                                                ebColor: kFormStockColor,
                                                controller: email,
                                              )),
                                        ],
                                      ),
                                      SizedBox(width: 25),
                                      Column(
                                        children: [
                                          SizedBox(height: 25),
                                          SizedBox(
                                              width: 150,
                                              height: 40,
                                              child: Center(
                                                child: FixedPrimary(
                                                    buttonText: 'Reset Password',
                                                    ontap: () async {
                                                      try {
                                                        if (email.text.isNotEmpty) {
                                                          //send password rest email
                                                          await FirebaseAuth.instance
                                                              .sendPasswordResetEmail(email: email.text)
                                                              .whenComplete(() => Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                      builder: (context) => ErrorDialog(
                                                                          title: 'Success',
                                                                          message:
                                                                              'An email for reset password has been sent to your email address. Please see inbox/spam to reset password',
                                                                          type: 'S',
                                                                          function: () {
                                                                            Navigator.pop(context);
                                                                          },
                                                                          buttontxt: 'Close'))));
                                                        } else {
                                                          showMsg('write a valid email',
                                                              Icon(Icons.close), context);
                                                        }
                                                      } catch (e) {
                                                        showMsg(
                                                            e.toString(), Icon(Icons.close), context);
                                                      }
                                                    }),
                                              )),
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 25),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 54.62),
                          Container(
                            width: 870,
                            height: 394,
                            decoration: BoxDecoration(
                              border: Border.all(width: 1, color: kFormStockColor),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 23),
                              child: Column(
                                children: [
                                  SizedBox(height: 25),
                                  Row(
                                    children: [
                                      // Column(
                                      //   crossAxisAlignment: CrossAxisAlignment.start,
                                      //   children: [
                                      //     Text(
                                      //       'Lodge Name',
                                      //       style: TextStyle(
                                      //           fontSize: 12, fontWeight: FontWeight.w500, color: kUIDark),
                                      //     ),
                                      //     SizedBox(height: 10),
                                      //     SizedBox(
                                      //       width: 221,
                                      //       height: 43,
                                      //       child: TextFieldWidget(
                                      //         hintText: '',
                                      //         ebColor: kFormStockColor,
                                      //       ),
                                      //     ),
                                      //   ],
                                      // ),
                                      // SizedBox(width: 25),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'New Email',
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                color: kUIDark),
                                          ),
                                          SizedBox(height: 10),
                                          SizedBox(
                                            width: 221,
                                            height: 43,
                                            child: TextFieldWidget(
                                              hintText: '',
                                              ebColor: kFormStockColor,
                                              controller: newEmail,
                                              validate: true,
                                              errorTxt: 'enter email',
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(width: 25),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Phone',
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                color: kUIDark),
                                          ),
                                          SizedBox(height: 10),
                                          SizedBox(
                                            width: 221,
                                            height: 43,
                                            child: TextFieldWidget(
                                              hintText: '',
                                              ebColor: kFormStockColor,
                                              controller: phone,
                                              validate: true,
                                              errorTxt: 'enter phone',
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(width: 25),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Address',
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                color: kUIDark),
                                          ),
                                          SizedBox(height: 10),
                                          SizedBox(
                                            width: 221,
                                            height: 43,
                                            child: TextFieldWidget(
                                              hintText: '',
                                              ebColor: kFormStockColor,
                                              controller: address,
                                              validate: true,
                                              errorTxt: 'enter address',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 20),
                                  Row(
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'City',
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                color: kUIDark),
                                          ),
                                          SizedBox(height: 10),
                                          SizedBox(
                                            width: 221,
                                            height: 43,
                                            child: TextFieldWidget(
                                              hintText: '',
                                              ebColor: kFormStockColor,
                                              controller: city,
                                              errorTxt: 'enter text',
                                              validate: true,
                                              // suffixIcon: Icon(
                                              //   CupertinoIcons.arrow_down,
                                              //   size: 15,
                                              //   color: kColorBlue,
                                              // ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      //SizedBox(width: 25),
                                      // Column(
                                      //   crossAxisAlignment: CrossAxisAlignment.start,
                                      //   children: [
                                      //     Text(
                                      //       'Region',
                                      //       style: TextStyle(
                                      //           fontSize: 12, fontWeight: FontWeight.w500, color: kUIDark),
                                      //     ),
                                      //     SizedBox(height: 10),
                                      //     SizedBox(
                                      //       width: 221,
                                      //       height: 43,
                                      //       child: TextFieldWidget(
                                      //         hintText: '',
                                      //         ebColor: kFormStockColor,
                                      //       ),
                                      //     ),
                                      //   ],
                                      // ),
                                      SizedBox(width: 25),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Company Reg. Number',
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                color: kUIDark),
                                          ),
                                          SizedBox(height: 10),
                                          SizedBox(
                                            width: 221,
                                            height: 43,
                                            child: TextFieldWidget(
                                              hintText: '',
                                              ebColor: kFormStockColor,
                                              validate: true,
                                              errorTxt: 'enter reg no',
                                              controller: regNumber,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(width: 25),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'VAT',
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                color: kUIDark),
                                          ),
                                          SizedBox(height: 10),
                                          SizedBox(
                                            width: 221,
                                            height: 43,
                                            child: TextFieldWidget(
                                              hintText: '',
                                              ebColor: kFormStockColor,
                                              validate: true,
                                              errorTxt: 'enter vat',
                                              controller: vat,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 20),
                                  Row(
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Admin Name',
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                color: kUIDark),
                                          ),
                                          SizedBox(height: 10),
                                          SizedBox(
                                            width: 221,
                                            height: 43,
                                            child: TextFieldWidget(
                                              hintText: '',
                                              ebColor: kFormStockColor,
                                              controller: adminName,
                                              validate: true,
                                              errorTxt: 'enter admin name',
                                            ),
                                          ),
                                        ],
                                      ),
                                      // SizedBox(width: 25),
                                      // Column(
                                      //   crossAxisAlignment: CrossAxisAlignment.start,
                                      //   children: [
                                      //     Text(
                                      //       'Input',
                                      //       style: TextStyle(
                                      //           fontSize: 12, fontWeight: FontWeight.w500, color: kUIDark),
                                      //     ),
                                      //     SizedBox(height: 10),
                                      //     SizedBox(
                                      //       width: 221,
                                      //       height: 43,
                                      //       child: TextFieldWidget(
                                      //         hintText: '',
                                      //         ebColor: kFormStockColor,
                                      //       ),
                                      //     ),
                                      //   ],
                                      // ),
                                      SizedBox(width: 25),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Facebook Link',
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                color: kUIDark),
                                          ),
                                          SizedBox(height: 10),
                                          SizedBox(
                                            width: 221,
                                            height: 43,
                                            child: TextFieldWidget(
                                              hintText: '',
                                              ebColor: kFormStockColor,
                                              controller: fbLink,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(width: 25),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Instagram Link',
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                color: kUIDark),
                                          ),
                                          SizedBox(height: 10),
                                          SizedBox(
                                            width: 221,
                                            height: 43,
                                            child: TextFieldWidget(
                                              hintText: '',
                                              ebColor: kFormStockColor,
                                              controller: instaLink,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 20),
                                  Row(
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Website Link',
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                color: kUIDark),
                                          ),
                                          SizedBox(height: 10),
                                          SizedBox(
                                            width: 221,
                                            height: 43,
                                            child: TextFieldWidget(
                                              hintText: '',
                                              ebColor: kFormStockColor,
                                              controller: webLink,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 26),
                          SizedBox(
                            width: 870,
                            child: Center(
                              child: SizedBox(
                                width: 339,
                                height: 52,
                                child: FixedPrimary(
                                    buttonText: 'Save Changes',
                                    ontap: () {
                                      if (key.currentState!.validate()) {
                                        editPeofile();
                                      }
                                    }),
                              ),
                            ),
                          ),
                          SizedBox(height: 56),
                        ],
                      ),
                    )),
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
          email.text = data!.email!;
          newEmail.text = data!.email!;
          address.text = data!.address!;
          phone.text = data!.contact!;
          city.text = data!.city!;
          regNumber.text = data!.reg!;
          vat.text = data!.vat!;
          adminName.text = data!.admin!;
          fbLink.text = data!.fb!;
          instaLink.text = data!.insta!;
          webLink.text = data!.web!;
        });
      }

      QuerySnapshot catsnap = await FirebaseFirestore.instance
          .collection('categories')
          .where('companyid', isEqualTo: user.uid)
          .get();
      if (catsnap.docs.isNotEmpty) {
        setState(() {
          companyCategories = CategoryData.fromMap(catsnap.docs.first.data() as Map<String, dynamic>);
          for (var i in companyCategories!.category!) {
            selectedCategorise.add(i);
          }
        });
      }

      QuerySnapshot snapAdminCategory = await FirebaseFirestore.instance
          .collection('adminCategories')
          .where('active', isEqualTo: true)
          .get();
      if (snapAdminCategory.docs.isNotEmpty) {
        setState(() {
          catData = snapAdminCategory.docs
              .map((e) => AdminCategoryData.fromMap(e.data() as Map<String, dynamic>))
              .toList();
          categories = catData.map((e) => e.category.toString()).toList();
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

  //pcik image
  Future pickImage() async {
    // ignore: invalid_use_of_visible_for_testing_member
    final imageweb = await ImagePicker.platform.getImage(source: ImageSource.gallery);
    if (imageweb != null) {
      setState(() {
        img = imageweb;
      });
    }
  }

  // ammentites widget
  Widget addNewCategory(String categoryPresent, int index) {
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
            categoryPresent,
            style: const TextStyle(color: kPrimary1),
          ),
          InkWell(
            onTap: () {
              setState(() {
                selectedCategorise.removeAt(index);
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

  //saving category

  Future saveCategory() async {
    try {
      setState(() {
        isLoading = true;
      });
      QuerySnapshot snap = await FirebaseFirestore.instance
          .collection('categories')
          .where('companyid', isEqualTo: data!.id!)
          .get();

      if (snap.docs.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('categories')
            .doc(companyCategories!.id!)
            .update({'category': selectedCategorise}).whenComplete(() => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ErrorDialog(
                        title: 'Success',
                        message: 'Your categories has been successfully saved',
                        type: 'Successs',
                        function: () {
                          Navigator.pop(context);
                        },
                        buttontxt: 'Close'))));
      } else {
        //
        final newcat = FirebaseFirestore.instance.collection('categories').doc();
        CategoryData catdata =
            CategoryData(category: selectedCategorise, companyid: data!.id, id: newcat.id);
        await newcat.set(catdata.toMap()).whenComplete(() => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ErrorDialog(
                    title: 'Success',
                    message: 'Your categories has been successfully saved',
                    type: 'Sueecess',
                    function: () {
                      Navigator.pop(context);
                    },
                    buttontxt: 'Close'))));
      }
    } catch (e) {
      showMsg(
          e.toString(),
          Icon(
            Icons.close,
            color: Colors.red,
          ),
          context);
    } finally {
      setState(() {
        isLoading = false;
      });
      selectedCategorise.clear();
      QuerySnapshot catsnap = await FirebaseFirestore.instance
          .collection('categories')
          .where('companyid', isEqualTo: user.uid)
          .get();
      if (catsnap.docs.isNotEmpty) {
        setState(() {
          companyCategories = CategoryData.fromMap(catsnap.docs.first.data() as Map<String, dynamic>);
          for (var i in companyCategories!.category!) {
            selectedCategorise.add(i);
          }
        });
      }
    }
  }
//saving profile

  Future editPeofile() async {
    try {
      setState(() {
        isLoading = true;
      });
      var imgUrl = '';
      var EmailNew = '';
      if (img != null) {
        final firebaseStorage = FirebaseStorage.instance;
        var snapshot = await firebaseStorage.ref().child('/profile_picks/${data!.id}').putData(
              await img!.readAsBytes(),
              SettableMetadata(contentType: 'image/jpeg'),
            );
        var imgUrlNew = await snapshot.ref.getDownloadURL();
        setState(() {
          imgUrl = imgUrlNew;
        });
      } else {
        setState(() {
          imgUrl = data!.imgUrl!;
        });
      }
      if (email.text != newEmail.text) {
        final UserAuth = await FirebaseAuth.instance.currentUser!.updateEmail(newEmail.text);
        setState(() {
          EmailNew = newEmail.text;
        });
      } else {
        setState(() {
          EmailNew = email.text;
        });
      }
      CompanyData companyData = CompanyData(
          active: true,
          contact: phone.text,
          date: Timestamp.fromDate(DateTime.now()),
          email: EmailNew,
          id: data!.id,
          name: adminName.text,
          reg: regNumber.text,
          imgUrl: imgUrl,
          companyName: data!.companyName,
          address: address.text,
          physicalAddress: data!.physicalAddress,
          region: data!.region,
          city: city.text,
          vat: vat.text,
          admin: adminName.text,
          fb: fbLink.text,
          insta: instaLink.text,
          web: webLink.text,
          adminStatus: 'Accepted');
      await FirebaseFirestore.instance
          .collection('compnies')
          .doc(data!.id)
          .update(companyData.toMap())
          .whenComplete(() => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ErrorDialog(
                      title: 'Success',
                      message: 'Your Profile is Updated Successfully',
                      type: 'S',
                      function: () {
                        Navigator.pop(context);
                      },
                      buttontxt: 'Close'))));
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
