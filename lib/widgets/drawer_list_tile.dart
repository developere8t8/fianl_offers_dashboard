// ignore_for_file: prefer_const_constructors

import 'package:fianl_offer_dashboard/constants.dart';
import 'package:flutter/material.dart';

class DrawerListTile extends StatelessWidget {
  const DrawerListTile({
    super.key,
    required this.title,
    required this.press,
    required this.iconSrc,
  });

  final String title, iconSrc;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: press,
      horizontalTitleGap: 0.0,
      leading: Image.asset(
        iconSrc,
        color: kUIDark,
        height: 16,
      ),
      title: Text(
        title,
        style: TextStyle(color: kUIDark, fontSize: 13, fontWeight: FontWeight.w600),
      ),
    );
  }
}
