import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchResult extends StatefulWidget {
  final String search;
  SearchResult({required this.search});

  @override
  _SearchResult createState() => _SearchResult(search: search);
}

class _SearchResult extends State<SearchResult> {
  final String search;
  _SearchResult({required this.search});

  String capitalizeAllWord(String value) {
    // TODO: Test untuk huruf pertama atau setelah spasi harus besar dan huruf lainnya harus kecil
    var result = value[0].toUpperCase();
    for (int i = 1; i < value.length; i++) {
      if (value[i - 1] == " ") {
        result = result + value[i].toUpperCase();
      } else {
        result = result + value[i].toLowerCase();
      }
    }
    return result;
  }

  Map<String, TextEditingController> textEditingControllers = {};
  var textFields = <TextField>[];

  Future<List<dynamic>> getMenuByName(String name) async {
    List listMenu = [];
    await FirebaseFirestore.instance.collection("Stands").get().then((res) async {
      for (var doc in res.docs) {
        await FirebaseFirestore.instance.collection("Stands").doc(doc.id).collection("Menus").orderBy('name', descending: false).where('name', isGreaterThanOrEqualTo: name).where('name', isLessThanOrEqualTo: name + '\uf8ff').get().then((value) async {
          late String standName;
          await FirebaseFirestore.instance.collection("Stands").doc(doc.id).get().then((stand) {
            standName = stand!['name'];
          });
          for (var menu in value.docs) {
            Map menuMap = new Map();
            menuMap['standId'] = doc.id;
            menuMap['standName'] = standName;
            menuMap['menuId'] = menu.id;
            menuMap['menuTotal'] = menu.data()!['total'];
            menuMap['menuImg'] = menu.data()!['image'];
            menuMap['menuName'] = menu.data()!['name'];
            menuMap['menuPrice'] = menu.data()!['price'];
            listMenu.add(menuMap);
          }
        });
      }
    });

    listMenu.forEach((str) {
      var textEditingController = new TextEditingController(text: "1");
      //str['standId'] = id stand
      textEditingControllers.putIfAbsent(str['standId'], () => textEditingController);
      return textFields.add(TextField(
        controller: textEditingController,
        textAlign: TextAlign.center,
      ));
    });
  return listMenu;
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        title: Text("Search Result"),
      ),
      body: FutureBuilder(
        future: getMenuByName(search),
        builder: (context, snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if(snapshot.hasData && snapshot.data!.isNotEmpty) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
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
                            height: MediaQuery.of(context).size.height / 7,
                            child: Center(
                              child: ListTile(
                                dense: true,
                                visualDensity: VisualDensity(vertical: 3),
                                leading: ClipRRect(
                                  borderRadius:
                                  BorderRadius.circular(6),
                                  child: Image.network(
                                    snapshot.data![index]['menuImg'],
                                    width: 80,
                                    fit: BoxFit.fill,
                                    height: 400,
                                  ),
                                ),
                                title: Text(
                                  capitalizeAllWord(
                                      snapshot.data![index]['menuName']),
                                  style: const TextStyle(
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
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                        "Rp. ${snapshot.data![index]['menuPrice'].toString()}"),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Text(snapshot.data![index]['standName']),
                                  ],
                                ),
                                trailing: (snapshot.data![index]['menuTotal'] >= 1)
                                    ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                        width: 60,
                                        child: textFields[index]),
                                    IconButton(
                                      onPressed: () async {FocusManager.instance.primaryFocus?.unfocus();
                                        if (textEditingControllers[snapshot.data![index]['standId']] != null) {
                                          if (int.parse(textEditingControllers[snapshot.data![index]['standId']]!.text) >= 1) {
                                            if (await checkTotalMenu(snapshot.data![index]['standId'], snapshot.data![index]['menuId'], int.parse(textEditingControllers[snapshot.data![index]['standId']]!.text))) {
                                              addCart(snapshot.data![index]['standId'], snapshot.data![index]['menuId'],
                                                  int.parse(textEditingControllers[snapshot.data![index]['standId']]!.text), snapshot.data![index]['standName']).then((msg) {
                                                setState(() {
                                                  textEditingControllers[snapshot.data![index]['standId']]!.text = "1";
                                                  var snackBar = SnackBar(duration: const Duration(seconds: 2), content: Text(msg));
                                                  ScaffoldMessenger.of(
                                                      context)
                                                      .showSnackBar(
                                                      snackBar);
                                                });
                                              });
                                            } else {
                                              var snackBar = SnackBar(
                                                  duration: const Duration(seconds: 2),
                                                  content: Text(
                                                      "Total Melebihi Total Menu"));
                                              ScaffoldMessenger.of(
                                                  context)
                                                  .showSnackBar(
                                                  snackBar);
                                            }
                                          } else {
                                            var snackBar = SnackBar(
                                                duration: const Duration(seconds: 2),
                                                content: Text(
                                                    "Total Tidak Boleh Dibawah 1"));
                                            ScaffoldMessenger.of(
                                                context)
                                                .showSnackBar(snackBar);
                                          }
                                        } else {
                                          var snackBar = SnackBar(
                                              duration: const Duration(seconds: 2),
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
              },);
          } else if(snapshot.hasError) {
            return const Center(
              child: Text("Menu Yang Anda Cari Tidak Ada"),
            );
          } else {
            return const Center(
              child: Text("Menu Yang Anda Cari Tidak Ada"),
            );
          }
        },),
    );
  }
}
