import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:qanteen/addMenu.dart';
import 'package:qanteen/editMenu.dart';
import 'model/menu_model.dart';

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
        MenuModel menuModel = MenuModel(id: doc.id.toString(), name: doc.data()["name"], price: doc.data()['price'], imgUrl: doc.data()['image']);
        listStand.add(menuModel);
      }
    });
    return listStand;
  }

  Future<String> deleteMenu(String standId, String menuId) async {
    late String message;
    try {
      await FirebaseFirestore.instance.collection("Stands").doc(standId).collection("Menus").doc(menuId).delete().then((msg) {
        message = "Menu Berhasil di Hapus";
      }, onError: (e) {
        message = "Terjadi Masalah : ${e}";
      });
    } catch(e) {
      message = "Terjadi Masalah : ${e}";
    }
    return message;
  }

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Menu"),
          actions: [
            IconButton(
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
              icon: const Icon(Icons.restaurant_menu),
            )
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
                                        leading: Image.network(
                                            data[index].imgUrl),
                                        title: Text(
                                            data[index].name.toString()),
                                        subtitle: Text(
                                            "Rp. ${data[index].price.toString()}"),
                                        trailing: PopupMenuButton<int>(
                                            onSelected: (value) {
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
                                              }
                                            },
                                          itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
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
        ));
  }
}
