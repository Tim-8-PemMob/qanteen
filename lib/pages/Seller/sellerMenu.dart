import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:qanteen/model/menu_model.dart';
import 'package:qanteen/pages/Seller/addMenu.dart';
import 'package:qanteen/pages/Seller/sellerHistory.dart';
import 'package:qanteen/pages/Seller/editMenu.dart';
import 'package:qanteen/pages/Seller/standOrder.dart';
import 'package:qanteen/pages/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

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
  bool standExist = true;

  Future getStandById(String standId) async {
    await FirebaseFirestore.instance
        .collection('Stands')
        .doc(standId)
        .get()
        .then((data) {
      var stand = data.data();
      print(data.data());
      if (stand != null) {
        standExist = true;
        setState(() {
          standName = stand['name'].toString();
        });
      } else {
        standExist = false;
        setState(() {
          standName = "Deleted";
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

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  Future<void> deleteFcmToken(String standId) async {
    final prefs = await SharedPreferences.getInstance();
    final String? userUid = prefs.getString("userUid");

    var standData = await FirebaseFirestore.instance.collection("Stands").doc(standId);
    if (standData != null) {
      standData.update({
        'ownerFcmToken' : "",
      });
    }

    await FirebaseFirestore.instance.collection("Users").doc(userUid).update({
      'fcmToken' : "",
    });
  }

  Future<String> deleteUser() async {
    late String message;
    await FirebaseAuth.instance.currentUser!.delete().then((res) {
      message = "Berhasil Hapus Akun";
    }, onError: (e) {
      message = e.message.toString();
    });
    return message;
  }

  @override
  void initState() {
    super.initState();
    getStandById(standId);
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              showDialog<String>(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Logout ?'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.pop(context, 'Cancel'),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        deleteFcmToken(standId).then((value) {
                          signOut();
                          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => LoginPage()), (Route<dynamic> route) => false);
                        });
                      },
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.logout),
        ),
        title: Text("Menu, ${standName}"),
        backgroundColor: Colors.red[700],
        actions: [
          (standExist)? IconButton(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => StandOrder(standId: standId))),
              icon: Icon(Icons.menu_book))
          : const Center(),
          (standExist) ? IconButton(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => SellerHistory(standId: standId))),
              icon: Icon(Icons.history))
              : const Center(),
        ],
      ),
      body: (standExist)? FutureBuilder(
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
                                    style: const TextStyle(
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
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      Text(
                                          "Rp. ${data[index].price.toString()}"),
                                      (data[index].total != 0)
                                          ? Text(
                                              "Sisa : ${data[index].total.toString()} Porsi")
                                          : const Text("Menu Habis",
                                              style:
                                                  TextStyle(color: Colors.red)),
                                    ],
                                  ),
                                  trailing: PopupMenuButton<int>(
                                      onSelected: (value) async {
                                        if (value == 1) {
                                          Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (builder) =>
                                                          EditMenu(
                                                              standId: standId,
                                                              menuId:
                                                                  data[index]
                                                                      .id)))
                                              .then((msg) => setState(() {
                                                    var snackBar = SnackBar(
                                                        content: Text(msg));
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(snackBar);
                                                  }));
                                        } else if (value == 2) {
                                          showDialog<String>(
                                            context: context,
                                            builder: (BuildContext context) => AlertDialog(
                                              title: const Text('Delete'),
                                              content: const Text('Delete ?'),
                                              actions: <Widget>[
                                                TextButton(
                                                  onPressed: () => Navigator.pop(context, 'Cancel'),
                                                  child: const Text('Cancel'),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    deleteMenu(standId, data[index].id)
                                                        .then((msg) {
                                                      setState(() {
                                                        Fluttertoast.showToast(msg: msg);
                                                      });
                                                    });
                                                    Navigator.pop(context);
                                                  },
                                                  child: const Text('Delete'),
                                                ),
                                              ],
                                            ),
                                          );
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
      ) : Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Stand Anda Telah Di Hapus Silahkan Hubungi Admin"),
            Text("Atau"),
            TextButton(
              onPressed: () {
                showDialog<String>(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                    title: const Text('Hapus Akun'),
                    content: const Text('Apakah anda yakin akan menghapus akun anda ?'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.pop(context, 'Cancel'),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          deleteUser().then((res) {
                            if(res == "Berhasil Hapus Akun") {
                              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => LoginPage()), (Route<dynamic> route) => false);
                            } else {
                              Fluttertoast.showToast(msg: res);
                            }
                          });
                        },
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );
              },
              child: Text("Hapus Akun"),
            )
          ],
        ),
      ),
      floatingActionButton: (standExist)? FloatingActionButton(
        backgroundColor: Colors.red[700],
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
      ) : null,
    );
  }
}
