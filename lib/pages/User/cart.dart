import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qanteen/pages/User/home/components/SizeConfig.dart';
import 'package:qanteen/pages/User/userOrder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../model/cart_model.dart';

class Cart extends StatefulWidget {
  @override
  _Cart createState() => _Cart();
}

class _Cart extends State<Cart> {
  late TextEditingController _controller;
  late String userUid;

  String capitalizeAllWord(String value) {
    var result = value[0].toUpperCase();
    for (int i = 1; i < value.length; i++) {
      if (value[i - 1] == " ") {
        result = result + value[i].toUpperCase();
      } else {
        result = result + value[i];
      }
    }
    return result;
  }

  Future<void> getUserUid() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userUid = prefs.getString("userUid")!;
    setState(() {
      _controller = new TextEditingController(text: userUid);
    });
  }

  List userCartList = [];
  Future<List<CartModel>> getCartById() async {
    final prefs = await SharedPreferences.getInstance();
    final String? userUid = prefs.getString("userUid");

    var listCart = List<CartModel>.empty(growable: true);
    await FirebaseFirestore.instance
        .collection("Users")
        .doc(userUid)
        .collection("Cart")
        .get()
        .then((data) async {
      for (var doc in data.docs) {
        late String standName, menuName, imageUrl;
        late int menuPrice;

        await FirebaseFirestore.instance
            .collection("Stands")
            .doc(doc.data()['standId'])
            .get()
            .then((res) {
          var stand = res.data();
          if (stand != null) {
            standName = stand['name'];
          }
        });

        await FirebaseFirestore.instance
            .collection("Stands")
            .doc(doc.data()['standId'])
            .collection("Menus")
            .doc(doc.data()['menuId'])
            .get()
            .then((res) {
          var menu = res.data();
          if (menu != null) {
            menuName = menu['name'];
            imageUrl = menu['image'];
            menuPrice = menu['price'];
          }
        });

        CartModel cartModel = CartModel(
            id: doc.id,
            menuId: doc.data()['menuId'],
            menuName: menuName,
            menuPrice: menuPrice,
            standId: doc.data()['standId'],
            standName: standName,
            total: doc.data()['total'],
            imageUrl: imageUrl);
        listCart.add(cartModel);
      }
    });
    userCartList = listCart;
    return listCart;
  }

  Future<String> removeCart(
      String standId, String menuId, String cartDocId, int totalReduce) async {
    final prefs = await SharedPreferences.getInstance();
    final String? userUid = prefs.getString("userUid");

    late String message;

    await FirebaseFirestore.instance
        .collection("Users")
        .doc(userUid)
        .collection("Cart")
        .doc(cartDocId)
        .delete()
        .then((value) async {
      await changePortionMenu(standId, menuId, totalReduce);
      message = "Menu Berhasil Dihapus Dari Cart";
    }, onError: (e) {
      message = "Terjadi Kelasalahn ${e}";
    });
    return message;
  }

  Future<void> changePortionMenu(
      String standId, String menuId, int totalBuy) async {
    await FirebaseFirestore.instance
        .collection("Stands")
        .doc(standId)
        .collection("Menus")
        .doc(menuId)
        .update({
      "total": FieldValue.increment(totalBuy),
    });
  }

  Future<String> changeTotalCart(
      String standId, String menuId, String cartDocId, int total) async {
    print("total : ${total}");
    late String message;
    await FirebaseFirestore.instance
        .collection("Users")
        .doc(userUid)
        .collection("Cart")
        .doc(cartDocId)
        .get()
        .then((data) async {
      if (data['total'] + total >= 1) {
        await FirebaseFirestore.instance
            .collection("Users")
            .doc(userUid)
            .collection("Cart")
            .doc(cartDocId)
            .update({
          "total": FieldValue.increment(total),
        }).then((res) async {
          await changePortionMenu(standId, menuId, total);
          message = "Total Menu Berhasil Di Ubah";
        }, onError: (e) {
          message = "Terjadi Kelasalahn ${e}";
        });
      } else {
        await removeCart(standId, menuId, cartDocId, 1).then((res) {
          message = "Menu Berhasil Di Hapus Dari Cart";
        });
      }
    });
    return message;
  }

  Future<String> PlaceOrder() async {
    Timestamp orderTime = Timestamp.fromDate(DateTime.now());
    final prefs = await SharedPreferences.getInstance();
    final String? userUid = prefs.getString("userUid");
    late String message;

    late String userName, menuName;
    late int menuPrice;
    await FirebaseFirestore.instance
        .collection("Users")
        .doc(userUid)
        .get()
        .then((data) {
      var user = data.data();
      if (user != null) {
        userName = user['name'];
      }
    });

    await FirebaseFirestore.instance
        .collection("Users")
        .doc(userUid)
        .collection("Cart")
        .get()
        .then((res) async {
      for (var doc in res.docs) {
        await FirebaseFirestore.instance
            .collection("Stands")
            .doc(doc.data()['standId'])
            .collection("Menus")
            .doc(doc.data()['menuId'])
            .get()
            .then((data) {
          var menu = data.data();
          if (menu != null) {
            menuName = menu['name'];
            menuPrice = menu['price'];
          }
        });
        // masukkan data ke order collections
        // hapus semua data di cart collections
        await FirebaseFirestore.instance
            .collection("Stands")
            .doc(doc.data()['standId'])
            .collection("Orders")
            .add({
          "userUid": userUid,
          "menuId": doc.data()['menuId'],
          "standId": doc.data()['standId'],
          "standName": doc.data()['standName'],
          "userName": userName,
          "menuName": menuName, // harga per menu atau total harga pesanan
          "menuPrice": menuPrice,
          "total": doc.data()['total'],
          "timeOrder": orderTime,
          "status": "Pending",
        }).then((res) async {
          await FirebaseFirestore.instance
              .collection("Users")
              .doc(userUid)
              .collection("Orders")
              .add({
            "refOrder": res,
            "timeOrder": orderTime,
          });
          await FirebaseFirestore.instance
              .collection("Users")
              .doc(userUid)
              .collection("Cart")
              .doc(doc.id)
              .delete();
        });
      }
      message = "Order Berhasil Di Kirim";
    }, onError: (e) {
      message = "Terjadi Kesalahan ${e}";
    });
    return message;
  }

  int countTotalPrice(List<dynamic> listMenu) {
    if(listMenu.isEmpty) {
      return 0;
    }
    late int totalPrice;
    for(var menu in listMenu) {
      totalPrice += int.parse(menu.total * menu.menuPrice);
    }
    return totalPrice;
  }

  @override
  void initState() {
    super.initState();
    userUid = "";
    getUserUid();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cart"),
        backgroundColor: Colors.red[700],
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => UserOrder(userUid: userUid)));
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
                      margin: EdgeInsets.all(5),
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(12)),
                      ),
                      child: InkWell(
                          onTap: () {
                            // Navigator.push(context, MaterialPageRoute(builder: (context) => Menu(standId : data[index].id)));
                          },
                          child: SizedBox(
                              height: 120,
                              child: Center(
                                child: ListTile(
                                    leading: ClipRRect(
                                        borderRadius: BorderRadius.circular(6),
                                        child: Image.network(
                                          data[index].imageUrl,
                                          width: 85,
                                        )),
                                    title: Text(capitalizeAllWord(
                                        "Menu : ${data[index].menuName.toString()}")),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          capitalizeAllWord(
                                              "Stand : ${data[index].standName.toString()}"),
                                        ),
                                        Text(
                                            "Total : ${data[index].total.toString()}")
                                      ],
                                    ),
                                    trailing: Container(
                                      height: double.maxFinite,
                                      child: Column(
                                        // mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              removeCart(
                                                      data[index].standId,
                                                      data[index].menuId,
                                                      data[index].id,
                                                      data[index].total)
                                                  .then((msg) {
                                                setState(() {
                                                  var snackBar = SnackBar(
                                                      duration: const Duration(
                                                          seconds: 2),
                                                      content: Text(msg));
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(snackBar);
                                                });
                                              });
                                            },
                                            child: const Icon(Icons.delete),
                                          ),
                                          SizedBox(
                                            height: 8,
                                          ),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              InkWell(
                                                  onTap: () {
                                                    changeTotalCart(
                                                            data[index].standId,
                                                            data[index].menuId,
                                                            data[index].id,
                                                            1)
                                                        .then((msg) {
                                                      setState(() {
                                                        var snackBar = SnackBar(
                                                            duration:
                                                                const Duration(
                                                                    seconds: 2),
                                                            content: Text(msg));
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(
                                                                snackBar);
                                                      });
                                                    });
                                                  },
                                                  child: const Icon(Icons
                                                      .add_circle_outline)),
                                              const SizedBox(
                                                width: 15,
                                              ),
                                              InkWell(
                                                onTap: () {
                                                  // TODO: ganti parameter terakhir (total reduce) menjadi dinamis ???
                                                  changeTotalCart(
                                                          data[index].standId,
                                                          data[index].menuId,
                                                          data[index].id,
                                                          -1)
                                                      .then((msg) {
                                                    setState(() {
                                                      var snackBar = SnackBar(
                                                          duration:
                                                              const Duration(
                                                                  seconds: 2),
                                                          content: Text(msg));
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                              snackBar);
                                                    });
                                                  });
                                                },
                                                child: const Icon(Icons
                                                    .remove_circle_outline),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    )),
                              ))));
                });
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return const Center(
                child: Text("Anda Belum Menambahkan Data ke Cart"));
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Container(
        width: getProportionateScreenWidth(300),
        child: FloatingActionButton(
          backgroundColor: Colors.red[700],
          onPressed: () async {
            await PlaceOrder().then((msg) {
              setState(() {
                var snackBar = SnackBar(
                    duration: const Duration(seconds: 2), content: Text(msg));
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              });
            });
          },
          child: Container(
            alignment: Alignment.center,
            width: MediaQuery.of(context).size.width,
            height: 300,
            decoration: BoxDecoration(
              color: Colors.red[700],
              borderRadius: const BorderRadius.all(
                Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.monetization_on,
                ),
                Text("Check Out")
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          height: 130,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Total:",
                    style: TextStyle(
                      color: Colors.red[700],
                      fontSize: 22,
                    ),
                  ),
                  Text(
                    countTotalPrice(userCartList).toString(),
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.red[700],
                    ),
                  ),
                ],
              ),
              Container(
                alignment: Alignment.center,
                height: 50,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.red[700],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "Check Out",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
