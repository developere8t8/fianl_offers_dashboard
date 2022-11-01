import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fianl_offer_dashboard/pages/login_page.dart';
import 'package:fianl_offer_dashboard/pages/validate.dart';
import 'package:fianl_offer_dashboard/widgets/side_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class CheckAuth extends StatefulWidget {
  const CheckAuth({super.key});

  @override
  State<CheckAuth> createState() => _CheckAuthState();
}

class _CheckAuthState extends State<CheckAuth> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      body: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(), //chekcing auth status
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasData) {
              return const ValidateUser();
            } else if (snapshot.hasError) {
              return const LoginPage();
            } else {
              return const LoginPage();
            }
          }),
    ));
  }
}
