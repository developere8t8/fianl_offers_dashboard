import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fianl_offer_dashboard/models/company.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class SigninProvider extends ChangeNotifier {
  //google signin function starts here
  final googleSignin = GoogleSignIn();
  GoogleSignInAccount? _user;

  GoogleSignInAccount? get user => _user;

  Future googleLogin() async {
    try {
      final googleUser = await googleSignin.signIn();
      if (googleUser == null) {
        return;
      } else {
        _user = googleUser;
      }
      final googleauth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleauth.accessToken,
        idToken: googleauth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        QuerySnapshot snapshot = await FirebaseFirestore.instance
            .collection('compnies')
            .where('id', isEqualTo: user.uid)
            .get();
        if (snapshot.docs.isEmpty) {
          final addUser = FirebaseFirestore.instance.collection('compnies').doc(user.uid);
          CompanyData company = CompanyData(
              active: false,
              contact: user.phoneNumber,
              date: Timestamp.fromDate(DateTime.now()),
              email: user.email,
              id: user.uid,
              name: user.displayName,
              reg: '',
              imgUrl: user.photoURL,
              companyName: '',
              address: '',
              physicalAddress: '',
              region: '',
              admin: '',
              city: '',
              fb: '',
              insta: '',
              vat: '',
              web: '',
              adminStatus: 'Pending');

          addUser.set(company.toMap());
        } else {
          // final addUser = FirebaseFirestore.instance.collection('compnies').doc(user.uid);
          // addUser.update({
          //   //'contact': user.phoneNumber,
          //   'email': user.email,
          //   'name': user.displayName,
          // });
        }
      }

      notifyListeners();
    } catch (e) {
      throw e.toString();
    }
  }

  //google signin function ends here

  //logout function
  Future logOut() async {
    try {
      await googleSignin.disconnect();
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      await FirebaseAuth.instance.signOut();
    } finally {
      await FirebaseAuth.instance.signOut();
    }
  }
}
