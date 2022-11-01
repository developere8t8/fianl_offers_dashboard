import 'dart:html';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fianl_offer_dashboard/models/company.dart';
import 'package:fianl_offer_dashboard/pages/Auth.dart';
import 'package:fianl_offer_dashboard/pages/missingdata.dart';
import 'package:fianl_offer_dashboard/pages/pending.dart';
import 'package:fianl_offer_dashboard/pages/signup_page.dart';
import 'package:fianl_offer_dashboard/provider/signin.dart';
import 'package:fianl_offer_dashboard/widgets/error.dart';
import 'package:fianl_offer_dashboard/widgets/side_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ValidateUser extends StatefulWidget {
  const ValidateUser({super.key});

  @override
  State<ValidateUser> createState() => _ValidateUserState();
}

class _ValidateUserState extends State<ValidateUser> {
  @override
  void initState() {
    validateUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
        child: Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    ));
  }

  Future validateUser() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: FirebaseAuth.instance.currentUser!.email)
        .get();
    if (snapshot.docs.isEmpty) {
      QuerySnapshot snap = await FirebaseFirestore.instance
          .collection('compnies')
          .where('id', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .get();
      if (snap.docs.isNotEmpty) {
        CompanyData data = CompanyData.fromMap(snap.docs.first.data() as Map<String, dynamic>);
        if (data.companyName!.isEmpty) {
          // ignore: use_build_context_synchronously
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => const AddMissingData()));
        } else if (data.active == false) {
          // ignore: use_build_context_synchronously
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => const PendingStatus()));
        } else {
          // ignore: use_build_context_synchronously
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SideBar()));
        }
      } else {
        // ignore: use_build_context_synchronously
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SideBar()));
      }
    } else {
      // ignore: use_build_context_synchronously
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => ErrorDialog(
                  title: 'Alert',
                  message:
                      '${FirebaseAuth.instance.currentUser!.email} is already registered as user. Please use another email',
                  type: 'E',
                  function: () {
                    final logoutUser = Provider.of<SigninProvider>(context, listen: false);
                    logoutUser.logOut();
                    Navigator.pushReplacement(
                        context, MaterialPageRoute(builder: (context) => const CheckAuth()));
                  },
                  buttontxt: 'Close')));
    }
  }
}
