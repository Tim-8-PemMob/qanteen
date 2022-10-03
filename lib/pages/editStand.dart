import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qanteen/pages/index.dart';

class EditStand extends StatefulWidget {
  final String standId;

  EditStand({required this.standId});

  @override
  _EditStand createState() => _EditStand(standId: standId);
}

class _EditStand extends State<EditStand> {
  final String standId;

  _EditStand({required this.standId});

  TextEditingController tName = TextEditingController(text: "");

  Future getStandById(String standId) async {
    await FirebaseFirestore.instance.collection('Stands').doc(standId).get().then((data) {
      var stand = data.data();
      if (stand != null) {
        setState(() {
          tName = TextEditingController(text: stand['name'].toString());
        });
      }
    });
  }

  Future<String> editStand() async {
    late String message;
    await FirebaseFirestore.instance.collection("Stands").doc(standId).update({
      "name" : tName.text,
    }).then((res) {
      message = "Stand Berhasil Di Edit";
    }, onError: (e) {
      message = "Terjadi Masalah ${e}";
    });
    return message;
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getStandById(standId);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Stands"),
        actions: [
          IconButton(
              onPressed: () {
                deleteStandById(standId).then((msg) {
                  var snackBar = SnackBar(content: Text(msg));
                  if (msg == "Stand Berhasil Di Hapus") {
                    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => Index()), (Route<dynamic> route) => false);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  }
                });
              },
              icon: Icon(Icons.delete)),
        ],
      ),
      body: Center(
        child: Row(
          children: [
            Expanded(
                child: Column(
                  children: [
                    TextField(
                      controller: tName,
                      decoration: const InputDecoration(
                          hintText: "Nama Stand"
                      ),
                    ),
                    TextButton(
                        onPressed: () async => editStand().then((msg) {
                          var snackBar = SnackBar(content: Text(msg));
                          if (msg == "Stand Berhasil Di Edit") {
                            // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Menu(standId: standId)));
                            Navigator.pop(context, msg);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(snackBar);
                          }
                        }),
                        child: const Text("Input Menu")
                    )
                  ],
                ))
          ],
        ),
      ),
    );
  }
}