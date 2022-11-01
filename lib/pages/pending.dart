import 'package:fianl_offer_dashboard/provider/signin.dart';
import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:provider/provider.dart';

import '../widgets/button.dart';

class PendingStatus extends StatefulWidget {
  const PendingStatus({super.key});

  @override
  State<PendingStatus> createState() => _PendingStatusState();
}

class _PendingStatusState extends State<PendingStatus> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      body: Center(
        child: SizedBox(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Your account request is pending for admin approval',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(
                height: 10,
              ),
              const SizedBox(
                height: 150,
                width: 150,
                child: LoadingIndicator(
                  indicatorType: Indicator.orbit,
                  colors: [Colors.red, Colors.blue],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              SizedBox(
                width: 339,
                height: 52,
                child: FixedPrimary(
                    buttonText: 'Log out',
                    ontap: () {
                      final logout = Provider.of<SigninProvider>(context, listen: false);
                      logout.logOut();
                    }),
              ),
            ],
          ),
        ),
      ),
    ));
  }
}
