import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:qanteen/pages/User/cart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../model/menu_model.dart';

class Menu extends StatefulWidget {
  final String standId;

  Menu({required this.standId});
  @override
  _Menu createState() => _Menu(standId: standId);
}

class _Menu extends State<Menu> {
  final String standId;
  _Menu({required this.standId});

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

  Map<String, TextEditingController> textEditingControllers = {};
  var textFields = <TextField>[];

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

    listStand.forEach((str) {
      var textEditingController = new TextEditingController(text: "1");
      //str.id = id menu
      textEditingControllers.putIfAbsent(str.id, () => textEditingController);
      return textFields.add(TextField(
        controller: textEditingController,
        textAlign: TextAlign.center,
      ));
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
        backgroundColor: Colors.red[700],
        actions: [
          IconButton(
              onPressed: () => Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => Cart())),
              icon: Icon(Icons.shopping_cart)),
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
                                    // MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        height: 20,
                                      ),
                                      Text(
                                          "Rp. ${data[index].price.toString()}"),
                                    ],
                                  ),
                                  trailing: (data[index].total >= 1)
                                      ? Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            SizedBox(
                                                width: 60,
                                                child: textFields[index]),
                                            IconButton(
                                              onPressed: () async {
                                                FocusManager
                                                    .instance.primaryFocus
                                                    ?.unfocus();
                                                if (textEditingControllers[
                                                        data[index].id] !=
                                                    null) {
                                                  if (int.parse(
                                                          textEditingControllers[
                                                                  data[index]
                                                                      .id]!
                                                              .text) >=
                                                      1) {
                                                    if (await checkTotalMenu(
                                                        standId,
                                                        data[index].id,
                                                        int.parse(
                                                            textEditingControllers[
                                                                    data[index]
                                                                        .id]!
                                                                .text))) {
                                                      addCart(
                                                              standId,
                                                              data[index].id,
                                                              int.parse(textEditingControllers[
                                                                      data[index]
                                                                          .id]!
                                                                  .text),
                                                              standName)
                                                          .then((msg) {
                                                        setState(() {
                                                          textEditingControllers[
                                                                  data[index]
                                                                      .id]!
                                                              .text = "1";
                                                          var snackBar = SnackBar(
                                                              duration:
                                                                  const Duration(
                                                                      seconds:
                                                                          2),
                                                              content:
                                                                  Text(msg));
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                                  snackBar);
                                                        });
                                                      });
                                                    } else {
                                                      var snackBar = SnackBar(
                                                          duration:
                                                              const Duration(
                                                                  seconds: 2),
                                                          content: Text(
                                                              "Total Melebihi Total Menu"));
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                              snackBar);
                                                    }
                                                  } else {
                                                    var snackBar = SnackBar(
                                                        duration:
                                                            const Duration(
                                                                seconds: 2),
                                                        content: Text(
                                                            "Total Tidak Boleh Dibawah 1"));
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(snackBar);
                                                  }
                                                } else {
                                                  var snackBar = SnackBar(
                                                      duration: const Duration(
                                                          seconds: 2),
                                                      content: Text(
                                                          "Total Tidak Boleh Kosong"));
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(snackBar);
                                                }
                                              },
                                              icon:
                                                  Icon(Icons.add_shopping_cart),
                                            ),
                                          ],
                                        )
                                      : const Text("Menu Habis"),
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
    );
  }
}
