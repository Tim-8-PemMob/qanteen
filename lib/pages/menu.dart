import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:qanteen/pages/addMenu.dart';
import 'package:qanteen/pages/cart.dart';
import 'package:qanteen/pages/editMenu.dart';
import 'package:qanteen/pages/editStand.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/menu_model.dart';
import 'standOrder.dart';

class Menu extends StatefulWidget {
  final String standId;

  Menu({required this.standId});
  @override
  _Menu createState() => _Menu(standId: standId);
}

class _Menu extends State<Menu> {
  final String standId;

  _Menu({required this.standId});

  Future<List<MenuModel>> getMenuFireStore(String standId) async {
    var listStand = List<MenuModel>.empty(growable: true);
    await FirebaseFirestore.instance.collection("Stands").doc(standId).collection("Menus").get().then((data) {
      for (var doc in data.docs) {
        print("name : ${doc.data()['name']}");
        print("price : ${doc.data()['price']}");
        MenuModel menuModel = MenuModel(id: doc.id.toString(), name: doc.data()["name"], price: doc.data()['price'], total: doc.data()['total'], imgUrl: doc.data()['image']);
        listStand.add(menuModel);
      }
    });
    return listStand;
  }

  String standName = "Please Wait...";
  Future getStandById(String standId) async {
    await FirebaseFirestore.instance.collection('Stands').doc(standId).get().then((data) {
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
      await FirebaseFirestore.instance.collection("Stands").doc(standId).collection("Menus").doc(menuId).delete().then((msg) {
        deleteFile(standId, menuId);
        message = "Menu Berhasil di Hapus";
      }, onError: (e) {
        message = "Terjadi Masalah : ${e}";
      });
    } catch(e) {
      message = "Terjadi Masalah : ${e}";
    }
    return message;
  }

  Future<void> reducePortion(String standId, String menuId ,int totalBuy) async {
    await FirebaseFirestore.instance.collection("Stands").doc(standId).collection("Menus").doc(menuId).update({
      "total" : FieldValue.increment(totalBuy * -1),
    });
  }

  Future<String> addCart(String standId, String menuId, int total) async {
    // await FirebaseFirestore.instance.collection("Stands").doc(standId).collection("Menus").doc(menuId).get();
    final dbInstance = FirebaseFirestore.instance;
    final prefs = await SharedPreferences.getInstance();
    final String? userUid = prefs.getString("userUid");
    late String message;
    await dbInstance.collection("Users").doc(userUid).collection("Cart").where("menuId", isEqualTo: menuId).get().then((data) async {
      if (data.docs.isEmpty) {
        await FirebaseFirestore.instance.collection("Users").doc(userUid).collection("Cart").add({
          "standId" :standId,
          "menuId" : menuId,
          "total" : total,
        }).then((msg) async {
          await reducePortion(standId, menuId, total);
          message = "Menu Di Tambahkan Ke Cart";
        }, onError: (e) {
          message = "Terjadi Masalah ${e}";
        });
      } else {
        for(var doc in data.docs) {
          await FirebaseFirestore.instance.collection("Users").doc(userUid).collection("Cart").doc(doc.id).update({
            "total" : FieldValue.increment(total),
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
          actions: [
            IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => EditStand(standId: standId))).then((msg) => setState(() {
                          getStandById(standId);
                  var snackBar = SnackBar(content: Text(msg));
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                }));
              },
              icon: const Icon(Icons.edit),
            ),
            IconButton(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => Cart())),
                icon: Icon(Icons.shopping_cart)),
            IconButton(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => StandOrder(standId: standId))),
                icon: Icon(Icons.production_quantity_limits)),
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
                                height: 80,
                                child: Center(
                                    child: ListTile(
                                        leading: (data[index].imgUrl != "placeholder") ? Image.network(
                                            data[index].imgUrl) : Icon(Icons.restaurant_menu),
                                        title: Text(
                                            data[index].name.toString()),
                                        subtitle: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text("Rp. ${data[index].price.toString()}"),
                                            Text("Porsi : ${data[index].total.toString()}"),
                                          ],
                                        ),
                                        trailing: PopupMenuButton<int>(
                                            onSelected: (value) async {
                                              if (value == 1) {
                                                Navigator.push(context, MaterialPageRoute(builder: (builder) => EditMenu(standId: standId, menuId: data[index].id))).then(
                                                        (msg) => setState(() {
                                                          var snackBar = SnackBar(content: Text(msg));
                                                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                                        })
                                                );
                                              } else if (value == 2) {
                                                setState(() {
                                                  deleteMenu(standId, data[index].id).then((msg) {
                                                    var snackBar = SnackBar(content: Text(msg));
                                                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                                  });
                                                });
                                              } else if (value == 3) {
                                                // ubah total
                                                addCart(standId, data[index].id, 1).then((msg) {
                                                  setState(() {
                                                    var snackBar = SnackBar(content: Text(msg));
                                                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                                  });
                                                });
                                              }
                                            },
                                          itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
                                            const PopupMenuItem<int>(
                                                value: 1,
                                                child: const Text("Edit")),
                                            const PopupMenuItem<int>(
                                                value: 2,
                                                child: const Text("Delete")),
                                            const PopupMenuItem<int>(
                                                value: 3,
                                                child: const Text("Add To Cart"))
                                          ]),
                                      ),
                                    ))));
                  });
            } else if (snapshot.connectionState == ConnectionState.waiting){
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
