import 'package:fianl_offer_dashboard/pages/dash_board.dart';
import 'package:fianl_offer_dashboard/pages/login_page.dart';
import 'package:fianl_offer_dashboard/pages/signup_page.dart';
import 'package:flutter/material.dart';

class MyDraw extends StatefulWidget {
  @override
  State<MyDraw> createState() => _MyDrawState();
}

class _MyDrawState extends State<MyDraw> {
  int _selectedDestination = 0;

  // ignore: prefer_final_fields
  static List<Widget> _widgetOptions = <Widget>[
    const LoginPage(),
    const SignUpPage(),
    const MyDashboard(),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Drawer(
          child: ListView(
            // Important: Remove any padding from the ListView.
            children: [
              ListTile(
                iconColor: Colors.white,
                textColor: Colors.white,
                leading: const Icon(Icons.auto_graph),
                title: const Text('APP STATISICS'),
                onTap: () => selectDestination(0),
              ),
              const SizedBox(
                height: 30,
              ),
              ListTile(
                iconColor: Colors.white,
                textColor: Colors.white,
                leading: const Icon(Icons.fastfood),
                title: const Text('DISHES'),
                onTap: () => selectDestination(1),
                selectedColor: Colors.red,
              ),
              const SizedBox(
                height: 30,
              ),
              ListTile(
                iconColor: Colors.white,
                textColor: Colors.white,
                leading: const Icon(Icons.group),
                title: const Text('USER PROFILE'),
                onTap: () => selectDestination(2),
              ),
              const SizedBox(
                height: 30,
              ),
              ListTile(
                iconColor: Colors.white,
                textColor: Colors.white,
                leading: const Icon(Icons.question_answer_outlined),
                title: const Text('PREFRENCES QUESTIONS'),
                onTap: () => selectDestination(3),
              ),
              const SizedBox(
                height: 30,
              ),
              ListTile(
                iconColor: Colors.white,
                textColor: Colors.white,
                leading: const Icon(Icons.person),
                title: const Text('CREATE ADMIN'),
                onTap: () => selectDestination(4),
              ),
            ],
          ),
        ),
        Expanded(
          child: Scaffold(
            body: _widgetOptions.elementAt(_selectedDestination),
          ),
        ),
      ],
    );
  }

  void selectDestination(int index) {
    setState(() {
      _selectedDestination = index;
    });
  }
}
