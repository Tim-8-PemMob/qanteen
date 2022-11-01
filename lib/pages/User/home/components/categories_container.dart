import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class categoriesContainer extends StatelessWidget {
  const categoriesContainer({
    Key? key,
    required this.image,
    required this.name,
    required this.standId,
    required this.menuId,
    required this.standName,
  }) : super(key: key);

  final String image;
  final String name;
  final String standId;
  final String menuId;
  final String standName;

  Future<void> reducePortion(
      String standId, String menuId, int totalBuy) async {
    await FirebaseFirestore.instance
        .collection("Stands")
        .doc(standId)
        .collection("Menus")
        .doc(menuId)
        .update({
      "total": FieldValue.increment(totalBuy * -1),
    });
  }

  Future<bool> checkTotalMenu(
      String standId, String menuId, int totalBuy) async {
    late bool result;
    await FirebaseFirestore.instance
        .collection("Stands")
        .doc(standId)
        .collection("Menus")
        .doc(menuId)
        .get()
        .then((res) {
      if (res.data()!['total'] >= totalBuy) {
        result = true;
      } else {
        result = false;
      }
    });
    return result;
  }

  Future<String> addCart(String standId, String menuId, int total, String standName) async {
    // await FirebaseFirestore.instance.collection("Stands").doc(standId).collection("Menus").doc(menuId).get();
    final dbInstance = FirebaseFirestore.instance;
    final prefs = await SharedPreferences.getInstance();
    final String? userUid = prefs.getString("userUid");
    late String message;
    await dbInstance.collection("Users").doc(userUid).collection("Cart").where("menuId", isEqualTo: menuId).get().then((data) async {
      if (data.docs.isEmpty) {
        await FirebaseFirestore.instance.collection("Users").doc(userUid).collection("Cart").add({
          "standId": standId,
          "standName": standName,
          "menuId": menuId,
          "total": total,
        }).then((msg) async {
          await reducePortion(standId, menuId, total);
          message = "Menu Di Tambahkan Ke Cart";
        }, onError: (e) {
          message = "Terjadi Masalah ${e}";
        });
      } else {
        for (var doc in data.docs) {
          await FirebaseFirestore.instance.collection("Users").doc(userUid).collection("Cart").doc(doc.id).update({
            "total": FieldValue.increment(total),
          }).then((msg) async {
            await reducePortion(standId, menuId, total);
            message = "Menu Di Tambahkan Ke Cart";
          }, onError: (e) {
            message = "Terjadi Masalah ${e}";
          });
        }
      }
    });
    return message;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              margin: EdgeInsets.only(left: 20),
              height: 80,
              width: 120,
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.fill,
                  image: NetworkImage(image),
                ),
                color: Colors.grey,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                height: 30,
                width: 30,
                decoration: BoxDecoration(
                    shape: BoxShape.circle, color: Colors.red[700]),
                child: IconButton(
                  icon: const Icon(Icons.shopping_cart),
                  onPressed: () {
                    addCart(standId, menuId, 1, standName).then((msg) {
                      var snackBar = SnackBar(
                          duration: const Duration(
                              seconds: 2),
                          content: Text(msg));
                      ScaffoldMessenger.of(context)
                          .showSnackBar(snackBar);
                    });
                  },
                  color: Colors.white,
                  padding: EdgeInsets.zero,
                ),
              ),
            ),
          ],
        ),
        // Padding(
        //   padding: const EdgeInsets.only(top: 3),
        //   child: Text(
        //     textAlign: TextAlign.center,
        //     name,
        //     style: TextStyle(
        //       fontSize: 20,
        //       color: Colors.black,

        //     ),
        //   ),
        // )
      ],
    );
  }
}
