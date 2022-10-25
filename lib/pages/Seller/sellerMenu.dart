import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:qanteen/model/menu_model.dart';
import 'package:qanteen/pages/Seller/addMenu.dart';
import 'package:qanteen/pages/User/cart.dart';
import 'package:qanteen/pages/Seller/editMenu.dart';
import 'package:qanteen/pages/Admin/editStand.dart';
import 'package:qanteen/pages/Seller/standOrder.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SellerMenu extends StatefulWidget {
  final String standId;

  SellerMenu({required this.standId});
  @override
  _SellerMenu createState() => _SellerMenu(standId: standId);
}

class _SellerMenu extends State<SellerMenu> {
  final String standId;

  _SellerMenu({required this.standId});

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

  Future<List<MenuModel>> getMenuFireStore(String standId) async {
    var listStand = List<MenuModel>.empty(growable: true);
    await FirebaseFirestore.instance
        .collection("Stands")
        .doc(standId)
        .collection("Menus")
        .get()
        .then((data) {
      for (var doc in data.docs) {
        print("name : ${doc.data()['name']}");
        print("price : ${doc.data()['price']}");
        MenuModel menuModel = MenuModel(
            id: doc.id.toString(),
            name: doc.data()["name"],
            price: doc.data()['price'],
            total: doc.data()['total'],
            imgUrl: doc.data()['image']);
        listStand.add(menuModel);
      }
    });
    return listStand;
  }

  String standName = "Please Wait...";
  Future getStandById(String standId) async {
    await FirebaseFirestore.instance
        .collection('Stands')
        .doc(standId)
        .get()
        .then((data) {
      var stand = data.data();
      if (stand != null) {
        setState(() {
          standName = stand['name'].toString();
        });
      }
    });
  }

  Future deleteFile(String standId, String menuId) async {
    final storageRef = FirebaseStorage.instance.ref();

    final imgDelete = storageRef.child("${standId}/${menuId}");
    await imgDelete.delete().then((msg) {
      print("Berhasil");
    }, onError: (e) {
      print("Error ${e}");
    });
  }

  Future<String> deleteMenu(String standId, String menuId) async {
    late String message;
    try {
      await FirebaseFirestore.instance
          .collection("Stands")
          .doc(standId)
          .collection("Menus")
          .doc(menuId)
          .delete()
          .then((msg) {
        deleteFile(standId, menuId);
        message = "Menu Berhasil di Hapus";
      }, onError: (e) {
        message = "Terjadi Masalah : ${e}";
      });
    } catch (e) {
      message = "Terjadi Masalah : ${e}";
    }
    return message;
  }

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

  Future<String> addCart(
      String standId, String menuId, int total, String standName) async {
    // await FirebaseFirestore.instance.collection("Stands").doc(standId).collection("Menus").doc(menuId).get();
    final dbInstance = FirebaseFirestore.instance;
    final prefs = await SharedPreferences.getInstance();
    final String? userUid = prefs.getString("userUid");
    late String message;
    await dbInstance
        .collection("Users")
        .doc(userUid)
        .collection("Cart")
        .where("menuId", isEqualTo: menuId)
        .get()
        .then((data) async {
      if (data.docs.isEmpty) {
        await FirebaseFirestore.instance
            .collection("Users")
            .doc(userUid)
            .collection("Cart")
            .add({
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
          await FirebaseFirestore.instance
              .collection("Users")
              .doc(userUid)
              .collection("Cart")
              .doc(doc.id)
              .update({
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
  void initState() {
    // TODO: implement initState
    super.initState();
    getStandById(standId);
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Menu, ${standName}"),
        backgroundColor: Colors.redAccent,
        actions: [
          IconButton(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => StandOrder(standId: standId))),
              icon: Icon(Icons.menu_book)),
        ],
      ),
      body: FutureBuilder(
        future: getMenuFireStore(standId),
        builder: (context, snapshot) {
          var data = snapshot.data;
          if (snapshot.hasError) {
            return Text("Error : ${snapshot.error.toString()}");
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
                        borderRadius:
                            const BorderRadius.all(Radius.circular(12)),
                      ),
                      child: InkWell(
                          child: SizedBox(
                              height: 110,
                              child: Center(
                                child: ListTile(
                                  dense: true,
                                  visualDensity: VisualDensity(vertical: 3),
                                  leading: (data[index].imgUrl != "placeholder")
                                      ? ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(6),
                                          child: Image.network(
                                            data[index].imgUrl,
                                            width: 80,
                                            fit: BoxFit.fill,
                                            height: 400,
                                          ),
                                        )
                                      : Icon(Icons.restaurant_menu),
                                  title: Text(
                                    capitalizeAllWord(
                                        data[index].name.toString()),
                                    style: TextStyle(
                                      fontSize: 19,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  subtitle: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    // mainAxisAlignment:
                                    //     MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        height: 20,
                                      ),
                                      Text("Rp. ${data[index].price.toString()}"),
                                      (data[index].total != 0)?
                                      Text("Sisa : ${data[index].total.toString()} Porsi")
                                          :
                                      const Text("Menu Habis", style: TextStyle(color: Colors.red)),
                                    ],
                                  ),
                                  trailing: PopupMenuButton<int>(
                                      onSelected: (value) async {
                                        if (value == 1) {
                                          Navigator.push(context, MaterialPageRoute(builder: (builder) => EditMenu(standId: standId, menuId: data[index].id))).then((msg) => setState(() {
                                            var snackBar = SnackBar(content: Text(msg));
                                            ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                          }));
                                        } else if (value == 2) {
                                          deleteMenu(standId, data[index].id).then((msg) {
                                            setState(() {
                                              var snackBar = SnackBar(content: Text(msg));
                                              ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                            });
                                          });
                                        }
                                      },
                                      itemBuilder: (BuildContext context) =>
                                          <PopupMenuEntry<int>>[
                                            const PopupMenuItem<int>(
                                                value: 1,
                                                child: const Text("Edit")),
                                            const PopupMenuItem<int>(
                                                value: 2,
                                                child: const Text("Delete")),
                                          ]),
                                ),
                              ))));
                });
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return const Center(
              child: Text("Tidak Ada Menu"),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.redAccent,
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => AddMenu(
                        standId: standId,
                      ))).then((msg) => setState(() {
                var snackBar = SnackBar(content: Text(msg));
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              }));
        },
        child: Icon(Icons.restaurant_menu),
      ),
    );
  }
}
