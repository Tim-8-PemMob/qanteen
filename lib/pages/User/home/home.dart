import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:qanteen/pages/User/profile.dart';
import 'components/Body.dart';

class home extends StatefulWidget {
  @override
  State<home> createState() => _homeState();
}

class _homeState extends State<home> {
  int currentIndex = 0;

  List<Widget> widgets = [
    Body(),
    Center(
      child: Text(
        "Tampilan Pesanan",
      ),
    ),
    Center(
      child: Text(
        "Tampilan Riwayat Pesanan",
      ),
    ),
    myProfile()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widgets[currentIndex],
      bottomNavigationBar: ConvexAppBar(
        // color: Colors.redAccent,
        backgroundColor: Colors.redAccent,
        items: [
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
