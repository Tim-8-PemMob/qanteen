import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddMenu extends StatefulWidget {
  final String standId;

  AddMenu({required this.standId});

  @override
  _AddMenu createState() => _AddMenu(standId: standId);
}

class _AddMenu extends State<AddMenu> {
  final String standId;

  _AddMenu({required this.standId});

  TextEditingController tName = TextEditingController(text: "");
  TextEditingController tPrice = TextEditingController(text: "");

  final ImagePicker imagePicker = ImagePicker();
  File? image;

  Future getImagePath() async {
    final pickedImg = await imagePicker.pickImage(source: ImageSource.gallery);
    print("image name : ${pickedImg!.name}");
    print("image path : ${pickedImg!.path}");
    setState(() {
      image = File(pickedImg!.path);
    });
  }

  Future<String> fileUpload(File imgPath, String standId, String menuId) async {
    final storageRef = FirebaseStorage.instance.ref();
    late String downloadUrl;
    final imgRef = storageRef.child("${standId}/${menuId}");
    try {
      await imgRef.putFile(imgPath);
      downloadUrl = await imgRef.getDownloadURL();
    } catch (e) {
      print("error : ${e}");
    }
    return downloadUrl;
  }

  Future<String> inputMenu(String standId, File imgPath) async {
    late String message;
    await FirebaseFirestore.instance.collection("Stands").doc(standId).collection("Menus").add({
      "image" : "placeholder",
      "name" : tName.text.toString(),
      "price" : int.parse(tPrice.text),
    }).then((res) async {
      await fileUpload(imgPath, standId, res.id).then((url) async {
        await FirebaseFirestore.instance.collection("Stands").doc(standId).collection("Menus").doc(res.id).update({
          "image" : url
        });
        message = "Menu Berhasil di Tambahkan";
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
        title: Text("Input Menu"),
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
                        hintText: "Nama Menu"
                      ),
                    ),
                    TextField(
                      keyboardType: TextInputType.number,
                      controller: tPrice,
                      decoration: const InputDecoration(
                          hintText: "Harga Menu"
                      ),
                    ),
                    TextButton(
                        onPressed: () async {
                          if (tName.text.isNotEmpty && tPrice.text.isNotEmpty && image != null){
                            inputMenu(standId, image!).then((msg) {
                              var snackBar = SnackBar(content: Text(msg));
                              if (msg == "Menu Berhasil di Tambahkan") {
                                Navigator.pop(context, msg);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                              }
                            });
                          } else {
                            var snackBar = SnackBar(content: Text("Tolong Masukkan Data Dengan Benar"));
                            ScaffoldMessenger.of(context).showSnackBar(snackBar);
                          }
                        },
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
