import 'package:fianl_offer_dashboard/constants.dart';
import 'package:fianl_offer_dashboard/pages/Auth.dart';
import 'package:fianl_offer_dashboard/pages/login_page.dart';
import 'package:fianl_offer_dashboard/provider/signin.dart';
import 'package:fianl_offer_dashboard/widgets/primary_swatch.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
//import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_strategy/url_strategy.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: const FirebaseOptions(
        apiKey: "AIzaSyCnET4VeiTWuCUxD1uEQpH7Icb7IEnv21c",
        authDomain: "finaloffer-b7bd5.firebaseapp.com",
        projectId: "finaloffer-b7bd5",
        storageBucket: "finaloffer-b7bd5.appspot.com",
        messagingSenderId: "703715756089",
        appId: "1:703715756089:web:ccaac16fe8e224ca6225e8",
        measurementId: "G-HFMY8XH78G"),
  );
  setPathUrlStrategy();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SigninProvider(),
      child: MaterialApp(
        title: 'Final Offer Dashboard',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          unselectedWidgetColor: kFormStockColor,
          scaffoldBackgroundColor: kColorWhite,
          primarySwatch: buildMaterialColor(const Color(0xFF3B71FE)),
          fontFamily: GoogleFonts.poppins().fontFamily,
        ),
        home: const CheckAuth(),
      ),
    );
  }
}
