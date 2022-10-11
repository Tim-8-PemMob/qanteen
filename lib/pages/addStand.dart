import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'index.dart';

class AddStand extends StatefulWidget {
  @override
  _AddStand createState() => _AddStand();
}

class _AddStand extends State<AddStand> {

  TextEditingController tName = TextEditingController(text: "");

  final ImagePicker imagePicker = ImagePicker();
  File? image;

  Future getImagePath() async {
    final pickedImg = await imagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      image = File(pickedImg!.path);
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

  Future<String> addStand() async {
    late String message;
    await FirebaseFirestore.instance.collection("Stands").add({
      "name" : tName.text.toString()
    }).then((res) async {
      await fileUpload(image!, res.id).then((url) async {
        await FirebaseFirestore.instance.collection("Stands").doc(res.id).update({
          "image" : url
        });
        message = "Stand Anda Berhasil Ditambahkan";
      }, onError: (e) {
        message = "Terjadi Error : ${e}";
      });
    });
    return message;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Stand"),
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
                    (image != null)?Image(
                        height: MediaQuery.of(context).size.height/5 ,
                        width: MediaQuery.of(context).size.height ,
                        image: FileImage(image!)
                    ):const Text("Image is Empty"),
                    TextField(
                      controller: tName,
                      decoration: const InputDecoration(
                        hintText: "Masukkan Nama Stand Anda",
                        labelText: "Nama Stand Anda ",
                      ),
                    ),
                    TextButton(
                        onPressed: () {
                          if (tName.text.isNotEmpty && image != null) {
                            addStand().then((msg) {
                              var snackBar = SnackBar(content: Text(msg));
                              if (msg == "Stand Anda Berhasil Ditambahkan") {
                                // Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => Index()), (Route<dynamic> route) => false);
                                Navigator.pop(context, msg);
                                tName = TextEditingController(text: "");
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                              }
                            });
                          } else {
                            var snackBar = SnackBar(content: Text("Tolong Masukkan Data Dengan Benar"));
                            ScaffoldMessenger.of(context).showSnackBar(snackBar);
                          }
                        },
                        child: const Text("Input Stand")
                    )
                  ],
                ))
          ],
        ),
      ),
    );
  }
}