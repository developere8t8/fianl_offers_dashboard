// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:fianl_offer_dashboard/pages/Auth.dart';
import 'package:fianl_offer_dashboard/pages/forgot.dart';
import 'package:fianl_offer_dashboard/provider/signin.dart';
import 'package:fianl_offer_dashboard/widgets/error.dart';
import 'package:fianl_offer_dashboard/pages/signup_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants.dart';
import '../widgets/button.dart';
import '../widgets/text_field.dart';
// Needed because we can't import `dart:html` into a mobile app,
// while on the flip-side access to `dart:io` throws at runtime (hence the `kIsWeb` check below)

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  final key = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Row(
          children: [
            Container(
              width: 600,
              height: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: const AssetImage('assets/images/login.jpg'),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(kColorBlack.withOpacity(0.3), BlendMode.darken),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    SizedBox(height: 150),
                    Text(
                      'Sign In to\nFinal Offer',
                      style: TextStyle(
                        fontSize: 55,
                        fontWeight: FontWeight.w700,
                        color: kColorWhite,
                      ),
                    ),
                    SizedBox(height: 30),
                    Text(
                      'Ut tellus quis in imperdiet pharetra.',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: kColorWhite,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              width: 150,
            ),
            SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 70,
                      ),
                      const Text(
                        'Hi, Welcome Back!',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: kUIDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 90,
                              ),
                              Center(
                                child: InkWell(
                                  onTap: () {
                                    final googleProvider =
                                        Provider.of<SigninProvider>(context, listen: false);
                                    googleProvider.googleLogin();
                                  },
                                  child: Container(
                                    width: 173,
                                    height: 52,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      border: Border.all(
                                        width: 1,
                                        style: BorderStyle.solid,
                                        color: kFormStockColor,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width: 13,
                                        ),
                                        Image.asset(
                                          'assets/icons/Google.png',
                                          scale: 4,
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                          'Sign in to Google',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: kUILight2,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              // const SizedBox(
                              //   width: 33,
                              // ),
                              // InkWell(
                              //   onTap: () async {
                              //     try {
                              //       final credential = await SignInWithApple.getAppleIDCredential(
                              //         scopes: [
                              //           AppleIDAuthorizationScopes.email,
                              //           AppleIDAuthorizationScopes.fullName,
                              //         ],
                              //         webAuthenticationOptions: WebAuthenticationOptions(
                              //           // TODO: Set the `clientId` and `redirectUri` arguments to the values you entered in the Apple Developer portal during the setup
                              //           clientId: 'finaloffer.com',

                              //           redirectUri:
                              //               // For web your redirect URI needs to be the host of the "current page",
                              //               // while for Android you will be using the API server that redirects back into your app via a deep link
                              //               kIsWeb
                              //                   ? Uri.parse('https://${window.location.host}')
                              //                   : Uri.parse(
                              //                       'https://flutter-sign-in-with-apple-example.glitch.me/callbacks/sign_in_with_apple',
                              //                     ),
                              //         ),
                              //       );

                              //       // ignore: avoid_print
                              //       print(credential);

                              //       // This is the endpoint that will convert an authorization code obtained
                              //       // via Sign in with Apple into a session in your system
                              //       final signInWithAppleEndpoint = Uri(
                              //         scheme: 'https',
                              //         host: '6xpert.pathcaresoft.com',
                              //         path: '/sign_in_with_apple',
                              //         queryParameters: <String, String>{
                              //           'code': credential.authorizationCode,
                              //           if (credential.givenName != null) 'firstName': credential.givenName!,
                              //           if (credential.familyName != null) 'lastName': credential.familyName!,
                              //           'useBundleId': !kIsWeb ? 'true' : 'false',
                              //           if (credential.state != null) 'state': credential.state!,
                              //         },
                              //       );

                              //       final session = await http.Client().post(
                              //         signInWithAppleEndpoint,
                              //       );

                              //       // If we got this far, a session based on the Apple ID credential has been created in your system,
                              //       // and you can now set this as the app's session
                              //       // ignore: avoid_print
                              //       print(session);
                              //     } catch (e) {
                              //       print(e);
                              //       // Navigator.push(
                              //       //     context,
                              //       //     MaterialPageRoute(
                              //       //         builder: (context) => ErrorDialog(
                              //       //             title: 'title',
                              //       //             message: e.toString(),
                              //       //             type: 'E',
                              //       //             function: () {
                              //       //               Navigator.pop(context);
                              //       //             },
                              //       //             buttontxt: 'Close')));
                              //     }
                              //   },
                              //   child: Container(
                              //     width: 173,
                              //     height: 52,
                              //     decoration: BoxDecoration(
                              //       borderRadius: BorderRadius.circular(5),
                              //       border: Border.all(
                              //         width: 1,
                              //         style: BorderStyle.solid,
                              //         color: kFormStockColor,
                              //       ),
                              //     ),
                              //     child: Row(
                              //       children: [
                              //         SizedBox(
                              //           width: 13,
                              //         ),
                              //         Image.asset(
                              //           'assets/icons/Apple.png',
                              //           scale: 4,
                              //         ),
                              //         SizedBox(
                              //           width: 10,
                              //         ),
                              //         Text(
                              //           'Sign in to Apple',
                              //           style: TextStyle(
                              //             fontSize: 14,
                              //             fontWeight: FontWeight.w600,
                              //             color: kUILight2,
                              //           ),
                              //         ),
                              //       ],
                              //     ),
                              //   ),
                              // )
                            ],
                          ),
                        ],
                      )
                    ],
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Row(
                    children: [
                      Container(
                        width: 132,
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(width: 1, color: kFormStockColor),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 9.5,
                      ),
                      Text(
                        'Or Sign in Email',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: kUILight2,
                        ),
                      ),
                      SizedBox(
                        width: 9.5,
                      ),
                      Container(
                        width: 132,
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(width: 1, color: kFormStockColor),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Form(
                      key: key,
                      child: Column(
                        children: [
                          Text(
                            'Email',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: kUIDark,
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          SizedBox(
                            width: 370,
                            height: 52,
                            child: TextFieldWidget(
                              controller: email,
                              validate: true,
                              errorTxt: 'enter email',
                              hintText: 'Enter email address',
                              ebColor: kUILight,
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Text(
                            'Password',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: kUIDark,
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          SizedBox(
                            width: 370,
                            height: 52,
                            child: TextFieldWidget(
                              controller: password,
                              errorTxt: 'enter password',
                              validate: true,
                              hintText: 'Enter password',
                              ebColor: kUILight,
                              // suffixIcon: Icon(
                              //   CupertinoIcons.eye_slash,
                              //   size: 17,
                              //   color: kUILight2,
                              // ),
                              obscure: true,
                            ),
                          ),
                          SizedBox(
                            height: 3,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              // Checkbox(
                              //   value: value,
                              //   shape: RoundedRectangleBorder(
                              //     borderRadius: BorderRadius.circular(3),
                              //   ),
                              //   onChanged: (value) => setState(() => this.value = value!),
                              // ),
                              // SizedBox(
                              //   width: 10,
                              // ),
                              // Text(
                              //   'Remember me',
                              //   style: TextStyle(
                              //     fontSize: 12,
                              //     fontWeight: FontWeight.w500,
                              //     color: kUIDark,
                              //   ),
                              // ),
                              SizedBox(
                                width: 130,
                              ),
                              InkWell(
                                onTap: () {
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (context) => ForgotPassword()));
                                },
                                child: Text(
                                  'Forgot password?',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: kPrimary1,
                                  ),
                                ),
                              )
                            ],
                          ),
                          SizedBox(height: 48),
                          FixedPrimary(
                            buttonText: 'Log in',
                            ontap: () {
                              if (key.currentState!.validate()) {
                                signInwithEmail();
                              }
                            },
                          ),
                        ],
                      )),
                  SizedBox(height: 30),
                  Wrap(
                    children: [
                      Text(
                        'Not registered yet? ',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: kUIDark,
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SignUpPage(),
                            ),
                          );
                        },
                        child: Text(
                          'Create an Account',
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: kPrimary1,
                          ),
                        ),
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

  //backend
  Future signInwithEmail() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: email.text, password: password.text);
      // ignore: use_build_context_synchronously
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CheckAuth(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        showMsg('Email not registered yet', Icon(Icons.close, color: Colors.red), context);
      } else {
        showMsg(e.code.toString(), Icon(Icons.close, color: Colors.red), context);
      }
    } catch (e) {
      showMsg(
          e.toString(),
          Icon(
            Icons.close,
            color: Colors.red,
          ),
          context);
    }
  }
}
