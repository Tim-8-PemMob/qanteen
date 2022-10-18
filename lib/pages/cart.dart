import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qanteen/pages/userOrder.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/cart_model.dart';

class Cart extends StatefulWidget {
  @override
  _Cart createState() => _Cart();
}

class _Cart extends State<Cart> {

  late TextEditingController _controller;
  late String userUid;

  Future<void> getUserUid() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userUid = prefs.getString("userUid")!;
    setState(() {
      _controller = new TextEditingController(text: userUid);
    });
  }

  Future<List<CartModel>> getCartById() async {
    final prefs = await SharedPreferences.getInstance();
    final String? userUid = prefs.getString("userUid");

    // DocumentReference standRef, menuRef;
    late String standName, menuName;
    var listCart = List<CartModel>.empty(growable: true);
    await FirebaseFirestore.instance.collection("Users").doc(userUid).collection("Cart").get().then((data) async {
      for (var doc in data.docs) {
        late String standName, menuName, imageUrl;

        await FirebaseFirestore.instance.collection("Stands").doc(doc.data()['standId']).get().then((res) {
          var stand = res.data();
          if(stand != null) {
            standName = stand['name'];
          }
        });

        await FirebaseFirestore.instance.collection("Stands").doc(doc.data()['standId']).collection("Menus").doc(doc.data()['menuId']).get().then((res) {
          var menu = res.data();
          if(menu != null) {
            menuName = menu['name'];
            imageUrl = menu['image'];
          }
        });
        // standRef = FirebaseFirestore.instance.doc(doc.data()["standId"].path);
        // menuRef = FirebaseFirestore.instance.doc(doc.data()['menuId'].path);
        //
        // await standRef.get().then((DocumentSnapshot documentSnapshot) {
        //   if (documentSnapshot.exists) {
        //     // print(documentSnapshot['name']);
        //     standName = documentSnapshot['name'];
        //   }
        // });
        //
        // await menuRef.get().then((DocumentSnapshot documentSnapshot) {
        //   if (documentSnapshot.exists) {
        //     // print(documentSnapshot['name']);
        //     menuName = documentSnapshot['name'];
        //     imageUrl = documentSnapshot['image'];
        //   }
        // });

        CartModel cartModel = CartModel(id: doc.id, menuId: doc.data()['menuId'], menuName: menuName, standId: doc.data()['standId'], standName: standName, total: doc.data()['total'], imageUrl: imageUrl);
        listCart.add(cartModel);
      }
    });
    return listCart;
  }

  Future<String> removeCart(String standId, String menuId, String cartDocId, int totalReduce) async {
    final prefs = await SharedPreferences.getInstance();
    final String? userUid = prefs.getString("userUid");

    late String message;

    await FirebaseFirestore.instance.collection("Users").doc(userUid).collection("Cart").doc(cartDocId).delete().then((value) async {
        await increasePortion(standId, menuId, totalReduce);
        message = "Menu Berhasil Dihapus Dari Cart";
      }, onError: (e) {
        message = "Terjadi Kelasalahn ${e}";
    });
    return message;
  }

  Future<void> increasePortion(String standId, String menuId, int totalBuy) async {
    await FirebaseFirestore.instance.collection("Stands").doc(standId).collection("Menus").doc(menuId).update({
      "total" : FieldValue.increment(totalBuy),
    });
  }

  Future<String> reduceTotal(String standId, String menuId, String cartDocId, int totalReduce) async {
    late String message;
    await FirebaseFirestore.instance.collection("Users").doc(userUid).collection("Cart").doc(cartDocId).get().then((data) async {
      if(data['total'] > 1) {
        print("inside if");
        await FirebaseFirestore.instance.collection("Users").doc(userUid).collection("Cart").doc(cartDocId).update({
          "total" : FieldValue.increment(totalReduce * -1),
        }).then((res) async {
          await increasePortion(standId, menuId, totalReduce);
          message = "Total Menu Berhasil Di Kurangi";
        }, onError: (e) {
          message = "Terjadi Kelasalahn ${e}";
        });
      } else {
        message = await removeCart(standId, menuId, cartDocId, 1);
      }
    });
    return message;
  }

  Future<void> PlaceOrder() async {
    Timestamp orderTime = Timestamp.fromDate(DateTime.now());
    final prefs = await SharedPreferences.getInstance();
    final String? userUid = prefs.getString("userUid");

    late String userName, menuName;
    late int menuPrice;
    await FirebaseFirestore.instance.collection("Users").doc(userUid).get().then((data) {
      var user = data.data();
      if (user != null) {
        userName = user['name'];
      }
    });

    await FirebaseFirestore.instance.collection("Users").doc(userUid).collection("Cart").get().then((res) async {
      for (var doc in res.docs) {

        await FirebaseFirestore.instance.collection("Stands").doc(doc.data()['standId']).collection("Menus").doc(doc.data()['menuId']).get().then((data) {
          var menu = data.data();
          if (menu != null) {
            menuName = menu['name'];
            menuPrice = menu['price'];
          }
        });
        // masukkan data ke order collections
        // hapus semua data di cart collections
        await FirebaseFirestore.instance.collection("Stands").doc(doc.data()['standId']).collection("Orders").add({
          "userUid" : userUid,
          "menuId" : doc.data()['menuId'],
          "standId" : doc.data()['standId'],
          "standName" : doc.data()['standName'],
          "userName" : userName,
          "menuName" : menuName, // harga per menu atau total harga pesanan
          "menuPrice" : menuPrice,
          "total" : doc.data()['total'],
          "status" : "Pending",
        }).then((res) async {
          await FirebaseFirestore.instance.collection("Users").doc(userUid).collection("Orders").add({
            "refOrder" : res,
            "timeOrder" : orderTime,
          });
          await FirebaseFirestore.instance.collection("Users").doc(userUid).collection("Cart").doc(doc.id).delete();
        });
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    userUid = "";
    getUserUid();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cart"),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => UserOrder(userUid: userUid)));
              },
              icon: Icon(Icons.query_builder))
        ],
      ),
      body: FutureBuilder(
        future: getCartById(),
        builder: (context, snapshot) {
          var data = snapshot.data;
          if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          } else if (data != null && data.isNotEmpty) {
            return ListView.builder(
                itemCount: data.length,
                itemBuilder: (context, index) {
                  return Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        borderRadius: const BorderRadius.all(Radius.circular(12)),
                      ),
                      child: InkWell(
                          onTap: () {
                            // Navigator.push(context, MaterialPageRoute(builder: (context) => Menu(standId : data[index].id)));
                          },
                          child: SizedBox (
                              height: 100,
                              child: Center (
                                  child : ListTile(
                                    leading: Image.network(data[index].imageUrl),
                                    title: Text("Menu : ${data[index].menuName.toString()}"),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("Stand : ${data[index].standName.toString()}"),
                                        Text("Total : ${data[index].total.toString()}")
                                      ],
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          onPressed: () {
                                            setState(()  {
                                              // ganti parameter terakhir (total reduce)
                                              reduceTotal(data[index].standId, data[index].menuId, data[index].id, 1).then((msg) {
                                                var snackBar = SnackBar(content: Text(msg));
                                                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                              });
                                            });
                                          },
                                          icon: const Icon(Icons.remove_circle_outline),
                                        ),
                                        IconButton(
                                          onPressed: () {
                                            setState(() {
                                              removeCart(data[index].standId, data[index].menuId, data[index].id, data[index].total).then((msg) {
                                                var snackBar = SnackBar(content: Text(msg));
                                                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                              });
                                            });
                                          },
                                          icon: const Icon(Icons.cancel),
                                        ),
                                      ],
                                    )
                                  )
                              )
                          )
                      )
                  );
                }
            );
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator()
            );
          } else {
            return const Center(
                child: Text("Anda Belum Menambahkan Data ke Cart")
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await PlaceOrder();
        },
        child: Icon(Icons.monetization_on),
      ),
    );
  }
}
