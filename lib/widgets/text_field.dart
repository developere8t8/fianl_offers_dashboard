// ignore_for_file: prefer_const_constructors

import 'package:fianl_offer_dashboard/constants.dart';
import 'package:flutter/material.dart';

class TextFieldWidget extends StatelessWidget {
  final String hintText;
  final Icon? suffixIcon;
  TextEditingController? controller;
  String? errorTxt;
  bool? validate;
  final onchange;
  final keyboradType;
  final obscure;
  final ebColor;

  TextFieldWidget(
      {Key? key,
      required this.hintText,
      this.suffixIcon,
      this.controller,
      this.errorTxt,
      this.validate,
      this.onchange,
      this.keyboradType,
      this.obscure,
      this.ebColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      obscureText: obscure ?? false,
      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: kUILight2),
      decoration: InputDecoration(
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: BorderSide(color: kUILight, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: BorderSide(color: ebColor, width: 1),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 20),
        // filled: true,
        // fillColor: kWhiteColor,
        hintText: hintText,
        hintStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: kUILight2,
        ),
      ),
      controller: controller,
      // ignore: body_might_complete_normally_nullable
      validator: (value) {
        if (validate != null) {
          if (value == null || value.isEmpty) {
            return errorTxt;
          }
          return null;
        }
      },
      onChanged: onchange,
      keyboardType: keyboradType,
    );
  }
}
