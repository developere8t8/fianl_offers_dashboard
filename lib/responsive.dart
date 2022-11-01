import 'package:flutter/material.dart';

class ResponsiveWidget extends StatelessWidget {
  final Widget mobile;
  final Widget tab;
  final Widget desktop;
  const ResponsiveWidget(
      {super.key,
      required this.mobile,
      required this.tab,
      required this.desktop});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth < 850) {
        return mobile;
      }
      if (constraints.maxWidth >= 850) {
        return tab;
      }
      if (constraints.maxWidth >= 1100) {
        return desktop;
      } else {
        return desktop;
      }
    });
  }
}
