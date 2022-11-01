// ignore_for_file: prefer_const_constructors, sort_child_properties_last

import 'package:fianl_offer_dashboard/constants.dart';
import 'package:flutter/material.dart';

class FixedPrimary extends StatelessWidget {
  final String buttonText;
  final Function ontap;
  const FixedPrimary({
    Key? key,
    required this.buttonText,
    required this.ontap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 374,
      height: 52,
      decoration: const BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.15),
            offset: Offset(0.0, 8.0),
            blurRadius: 24,
          ),
        ],
      ),
      child: OutlinedButton(
        onPressed: () {
          ontap();
        },
        style: ButtonStyle(
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(104),
            ),
          ),
          backgroundColor: MaterialStateProperty.all(kPrimary1),
          foregroundColor: MaterialStateProperty.all(kColorWhite),
          // padding: MaterialStateProperty.all(
          //   const EdgeInsets.symmetric(vertical: 14),
          // ),
          textStyle: MaterialStateProperty.all(
            const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        child: Text(buttonText),
      ),
    );
  }
}

class FixedSecondary extends StatelessWidget {
  final String buttonText;
  final Function ontap;
  const FixedSecondary({
    Key? key,
    required this.buttonText,
    required this.ontap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        ontap();
      },
      child: Row(
        children: [
          SizedBox(width: 8),
          Text(
            buttonText,
            style: TextStyle(
              color: kPrimary1,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 5),
          Icon(
            Icons.arrow_downward,
            color: kPrimary1,
            size: 15,
          ),
        ],
      ),
      style: TextButton.styleFrom(
        foregroundColor: kColorWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(20),
          ),
        ),
        side: BorderSide(color: kPrimary1, width: 1, style: BorderStyle.solid),
      ),
    );
  }
}
