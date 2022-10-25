import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qanteen/pages/index.dart';
import 'package:image_picker/image_picker.dart';

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
  final ImagePicker imagePicker = ImagePicker();
  File? image;
  String oldImage = "";
  String oldImgName = "";

  Future getImagePath() async {
    final pickedImg = await imagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      image = File(pickedImg!.path);
      oldImage = "";
    });
  }

  Future<String> fileUpload(File imgPath, String standId) async {
    final storageRef = FirebaseStorage.instance.ref();
    late String downloadUrl;
    final imgRef = storageRef.child("${standId}/${standId}");
    try {
      await imgRef.putFile(imgPath);
      downloadUrl = await imgRef.getDownloadURL();
    } catch (e) {
      print("error : ${e}");
    }
    return downloadUrl;
  }

  Future getStandById(String standId) async {
    await FirebaseFirestore.instance.collection('Stands').doc(standId).get().then((data) {
      var stand = data.data();
      if (stand != null) {
        setState(() {
          tName = TextEditingController(text: stand['name'].toString());
          oldImage = stand['image'];
        });
      }
    });
  }

  Future<String> editStand(File? image, String standId, String oldImageUrl) async {
    late String message;

    if(oldImage == "") {
      await fileUpload(image!, standId).then((url) async {
        await FirebaseFirestore.instance.collection("Stands").doc(standId).update({
          "name" : tName.text,
          "image" : url,
        });
        message = "Stand Berhasil Di Edit";
        }, onError: (e) {
        message = "Terjadi Masalah ${e}";
      });
    } else {
      await FirebaseFirestore.instance.collection("Stands").doc(standId).update({
        "name" : tName.text,
        "image" : oldImageUrl,
      }).then((res) {
        message = "Stand Berhasil Di Edit";
      }, onError: (e) {
        message = "Terjadi Masalah ${e}";
      });
    }
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
    super.initState();
    getStandById(standId);
  }

  @override
  Widget build(BuildContext context) {
    var img = image;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
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
              icon: const Icon(Icons.delete)),
        ],
      ),
      body: Center(
        child: Row(
          children: [
            Expanded(
                child: Column(
                  children: [
                    IconButton(
                        onPressed: () => getImagePath(),
                        icon: const Icon(Icons.image)
                    ),
                    (oldImage == "" && img != null)?
                    Image(
                        height: MediaQuery.of(context).size.height/5 ,
                        width: MediaQuery.of(context).size.height ,
                        image: FileImage(img))
                        : (oldImage == "" && img == null)?
                    const CircularProgressIndicator()
                        : Image(
                        height: MediaQuery.of(context).size.height/5 ,
                        width: MediaQuery.of(context).size.height ,
                        image: NetworkImage(oldImage)),
                    TextField(
                      controller: tName,
                      decoration: const InputDecoration(
                          hintText: "Nama Stand Anda",
                          labelText: "Nama Baru Stand Anda"
                      ),
                    ),
                    TextButton(
                        onPressed: () async => editStand(img, standId, oldImage).then((msg) {
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