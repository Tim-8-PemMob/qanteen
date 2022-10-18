import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qanteen/pages/User/cart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Body.dart';
import 'icon_btn_with_counter.dart';
import 'search_field.dart';

class HomeHeader extends StatefulWidget {
  @override
  _HomeHeader createState() => _HomeHeader();
}

class _HomeHeader extends State<HomeHeader> {

  int totalCart = 0;
  Future<void> countCart() async {
    final prefs = await SharedPreferences.getInstance();
    final String? userUid = prefs.getString("userUid");

    QuerySnapshot docSnap = await FirebaseFirestore.instance.collection("Users").doc(userUid).collection("Cart").get();
    List<DocumentSnapshot> cartSnapshot = docSnap.docs;
    setState(() {
      totalCart = cartSnapshot.length;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    countCart();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * (20 / 375),
        vertical: MediaQuery.of(context).size.width * (15 / 375),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          restaurantIcon(),
          searchField(),
          IconBtnWithCounter(
            iconSrc: Icons.shopping_cart,
            press: () {
              // TODO: delete this
              Navigator.push(context, MaterialPageRoute(builder: (builder) => Cart()));
            },
            numOfItems: totalCart,
          )
        ],
      ),
    );
  }
}

class restaurantIcon extends StatelessWidget {
  const restaurantIcon({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.width * (46 / 375),
      width: MediaQuery.of(context).size.width * (46 / 375),
      padding: EdgeInsets.all(MediaQuery.of(context).size.width * (10 / 375)),
      decoration: BoxDecoration(
          color: kCupertinoModalBarrierColor.withOpacity(0.1),
          shape: BoxShape.circle),
      child: FittedBox(
        child: Icon(Icons.restaurant_menu),
      ),
    );
  }
}
