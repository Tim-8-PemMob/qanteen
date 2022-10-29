import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:qanteen/pages/Admin/editStand.dart';
import 'package:qanteen/pages/User/home/home.dart';
import 'package:qanteen/pages/User/menu.dart';
import 'package:qanteen/model/stand_model.dart';
import 'addSeller.dart';

Future<List<StandModel>> getStandFireStore() async {
  var listStand = List<StandModel>.empty(growable: true);
  await FirebaseFirestore.instance.collection("Stands").get().then((data) {
    for (var doc in data.docs) {
      StandModel standModel = StandModel(id: doc.id.toString(), name: doc.data()["name"], image: doc.data()['image']);
      listStand.add(standModel);
    }
  });
  return listStand;
}

Future<String> deleteStandById(String standId) async {
  late String message;
  await FirebaseFirestore.instance.collection("Stands").doc(standId).delete().then((res) {
    deleteStandStorage(standId);
    message = "Stand Berhasil Di Hapus";
  }, onError: (e) {
    message = "Terjadi Kesalahan ${e}";
  });
  return message;
}

Future deleteStandStorage(String standId) async {
  await FirebaseStorage.instance.ref("${standId}").listAll().then((value) {
    value.items.forEach((element) {
      print("element : ${element}");
      FirebaseStorage.instance.ref(element.fullPath).delete();
    });
  });
}

class Index extends StatefulWidget {
  @override
  _Index createState() => _Index();
}

class _Index extends State<Index> {

  @override
  Widget build(BuildContext context) {
    getStandFireStore();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        title: const Text("Stand Makanan"),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (builder) => AddSeller()));
            },
            icon: Icon(Icons.add),),
        ],
      ),
      body: FutureBuilder(
        future: getStandFireStore(),
        builder: (context, snapshot) {
          var data = snapshot.data;
          if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          } else if (data != null && data.isNotEmpty) {
            // reference();
            // addMenu();
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
                          child: SizedBox (
                              height: 80,
                              child: Center (
                                  child : ListTile(
                                    leading: const Icon(Icons.food_bank),
                                    title: Text("${data[index].name.toString()}"),
                                    trailing: PopupMenuButton<int>(
                                        onSelected: (value) async {
                                          if (value == 1) {
                                            Navigator.push(context, MaterialPageRoute(builder: (builder) => EditStand(standId: data[index].id))).then((msg) => setState(() {
                                              var snackBar = SnackBar(content: Text(msg));
                                              ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                            }));
                                          } else if (value == 2) {
                                            deleteStandById(data[index].id).then((msg) {
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
                                  )
                              )
                          )
                      )
                  );
            }
            );
          } else if (snapshot.connectionState == ConnectionState.waiting){
            return const Center(
                child: CircularProgressIndicator()
            );
          } else {
            return const Center(
                child: Text("Stands Makanan Kosong")
            );
          }
        },
      ),
    );
  }
}