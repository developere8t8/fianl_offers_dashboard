// ignore_for_file: prefer_final_fields, prefer_const_constructors

import 'package:fianl_offer_dashboard/constants.dart';
import 'package:fianl_offer_dashboard/pages/Auth.dart';
import 'package:fianl_offer_dashboard/pages/dash_board.dart';
import 'package:fianl_offer_dashboard/pages/login_page.dart';

import 'package:fianl_offer_dashboard/pages/my_products.dart';
import 'package:fianl_offer_dashboard/pages/offers_data.dart';
import 'package:fianl_offer_dashboard/pages/new_product.dart';

import 'package:fianl_offer_dashboard/pages/profile_settings.dart';
import 'package:fianl_offer_dashboard/pages/settings.dart';
import 'package:fianl_offer_dashboard/pages/t_cs.dart';
import 'package:fianl_offer_dashboard/provider/signin.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SideBar extends StatefulWidget {
  int? page;
  SideBar({Key? key, this.page}) : super(key: key);

  @override
  State<SideBar> createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> {
  int _selectedDestination = 0;

  static List<Widget> _widgetOptions = [
    MyDashboard(),
    MyOffers(),
    MyProducts(),
    NewProduct(),
    ProfileSettings(),
    TCs(),
    Settings(),
  ];

  @override
  void initState() {
    if (widget.page != null) {
      _selectedDestination = widget.page!;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 165,
          child: Drawer(
            elevation: 1,
            backgroundColor: kColorWhite,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  Image.asset(
                    'assets/images/final_logo.png',
                    width: 90,
                    height: 62,
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  ListTile(
                    selectedTileColor: Color(0xFFE9F2FE),
                    selectedColor: kPrimary1,
                    horizontalTitleGap: 0.0,
                    title: const Text(
                      'Dashboard',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    leading: Image.asset(
                      'assets/icons/homei.png',
                      scale: 4,
                      color: kUIDark,
                    ),
                    selected: _selectedDestination == 0,
                    onTap: () => selectDestination(0),
                  ),
                  ListTile(
                    selectedTileColor: Color(0xFFE9F2FE),
                    selectedColor: kPrimary1,
                    horizontalTitleGap: 0.0,
                    title: const Text(
                      'Offers',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    leading: Image.asset(
                      'assets/icons/offr.png',
                      scale: 3,
                      color: kUIDark,
                    ),
                    selected: _selectedDestination == 1,
                    onTap: () => selectDestination(1),
                  ),
                  ListTile(
                    selectedTileColor: Color(0xFFE9F2FE),
                    selectedColor: kPrimary1,
                    horizontalTitleGap: 0.0,
                    title: const Text(
                      'My Products',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    leading: Image.asset(
                      'assets/icons/pinl.png',
                      scale: 3,
                      color: kUIDark,
                    ),
                    selected: _selectedDestination == 2,
                    onTap: () => selectDestination(2),
                  ),
                  ListTile(
                    selectedTileColor: Color(0xFFE9F2FE),
                    selectedColor: kPrimary1,
                    horizontalTitleGap: 0.0,
                    title: const Text(
                      'Add Products',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    leading: Icon(
                      Icons.new_label,
                      color: Colors.black,
                    ),
                    selected: _selectedDestination == 3,
                    onTap: () => selectDestination(3),
                  ),
                  ListTile(
                    selectedTileColor: Color(0xFFE9F2FE),
                    selectedColor: kPrimary1,
                    horizontalTitleGap: 0.0,
                    title: const Text(
                      'Profile Settings',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    leading: Image.asset(
                      'assets/icons/profile.png',
                      scale: 3,
                      color: kUIDark,
                    ),
                    selected: _selectedDestination == 4,
                    onTap: () {
                      selectDestination(4);
                    },
                  ),
                  // ListTile(
                  //   selectedTileColor: Color(0xFFE9F2FE),
                  //   selectedColor: kPrimary1,
                  //   horizontalTitleGap: 0.0,
                  //   title: const Text(
                  //     'T&Cs',
                  //     style: TextStyle(
                  //       fontSize: 13,
                  //       fontWeight: FontWeight.w600,
                  //     ),
                  //   ),
                  //   leading: Image.asset(
                  //     'assets/icons/tc.png',
                  //     scale: 4,
                  //     color: kUIDark,
                  //   ),
                  //   selected: _selectedDestination == 5,
                  //   onTap: () => selectDestination(5),
                  // ),
                  // ListTile(
                  //   selectedTileColor: Color(0xFFE9F2FE),
                  //   selectedColor: kPrimary1,
                  //   horizontalTitleGap: 0.0,
                  //   title: const Text(
                  //     'Settings',
                  //     style: TextStyle(
                  //       fontSize: 13,
                  //       fontWeight: FontWeight.w600,
                  //     ),
                  //   ),
                  //   leading: Image.asset(
                  //     'assets/icons/settings.png',
                  //     scale: 4,
                  //     color: kUIDark,
                  //   ),
                  //   selected: _selectedDestination == 6,
                  //   onTap: () => selectDestination(6),
                  // ),
                  const SizedBox(height: 123),
                  InkWell(
                    onTap: () {
                      final logout = Provider.of<SigninProvider>(context, listen: false);
                      logout.logOut().whenComplete(() => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CheckAuth(),
                            ),
                          ));
                    },
                    child: ListTile(
                      selectedTileColor: Color(0xFFE9F2FE),
                      selectedColor: kPrimary1,
                      horizontalTitleGap: 0.0,
                      title: const Text(
                        'Log out',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      leading: Image.asset(
                        'assets/icons/Logout.png',
                        scale: 3,
                        color: kUIDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
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
