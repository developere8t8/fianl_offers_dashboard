import 'package:fianl_offer_dashboard/pages/Auth.dart';
import 'package:fianl_offer_dashboard/widgets/button.dart';
import 'package:fianl_offer_dashboard/widgets/text_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../constants.dart';
import '../widgets/error.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  TextEditingController email = TextEditingController();
  final key = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            body: Form(
                key: key,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 400,
                      child: TextFieldWidget(
                        hintText: 'wirte your registered email',
                        controller: email,
                        errorTxt: 'email is required',
                        validate: true,
                        ebColor: kUIDark,
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Center(
                      child: FixedPrimary(
                          buttonText: 'Reset Password',
                          ontap: () {
                            if (key.currentState!.validate()) {
                              sendRestLink();
                            }
                          }),
                    ),
                  ],
                ))));
  }

  Future sendRestLink() async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email.text);

      // ignore: use_build_context_synchronously
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ErrorDialog(
                  title: 'Success',
                  message:
                      'Password reset email is sent on your email.If you not found email in Inbox please see spam folder',
                  type: 'S',
                  function: () {
                    Navigator.pushReplacement(
                        context, MaterialPageRoute(builder: (context) => const CheckAuth()));
                  },
                  buttontxt: 'Ok')));
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        showMsg('Email not registered', const Icon(Icons.close, color: Colors.red), context);
      } else {
        showMsg(e.code.toString(), const Icon(Icons.close, color: Colors.red), context);
      }
    } catch (e) {
      showMsg(e.toString(), const Icon(Icons.close, color: Colors.red), context);
    }
  }
}
