import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:qanteen/pages/User/userHistory.dart';
import 'package:qanteen/pages/User/profile.dart';
import 'package:qanteen/pages/User/userOrder.dart';
import 'components/Body.dart';

class home extends StatefulWidget {
  final String userUid;
  home({required this.userUid});

  @override
  State<home> createState() => _homeState(userUid: userUid);
}

class _homeState extends State<home> {
  final String userUid;
  _homeState({required this.userUid});

  DateTime? currentBackPressTime;
  Future<bool> onWillPop() {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null || now.difference(currentBackPressTime!) > const Duration(seconds: 2)) {
      currentBackPressTime = now;
      Fluttertoast.showToast(
        msg: "Press Back Again To Close App",
      );
      return Future.value(false);
    }
    return Future.value(true);
  }

  int currentIndex = 0;

  late List<Widget> widgets = [
    Body(),
    UserOrder(userUid: userUid),
    UserHistory(),
    const myProfile(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(onWillPop: onWillPop, child: widgets[currentIndex],),
      bottomNavigationBar: ConvexAppBar(
        // color: Colors.redAccent,
        height: MediaQuery.of(context).size.width * 0.15,
        backgroundColor: Colors.red[700],
        items: const [
          TabItem(icon: Icons.home, title: 'Home'),
          TabItem(icon: Icons.restaurant_menu, title: 'Pesanan'),
          TabItem(icon: Icons.history, title: 'History'),
          TabItem(icon: Icons.people, title: 'Profile'),
        ],
        onTap: (int i) {
          initialActiveIndex:
          0;
          setState(() {
            currentIndex = i;
          });
        },
      ),
    );
  }
}
