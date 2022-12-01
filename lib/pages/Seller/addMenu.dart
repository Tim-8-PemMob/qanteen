import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
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
  TextEditingController tTotal = TextEditingController(text: "");

  final ImagePicker imagePicker = ImagePicker();
  File? image;

  Future getImagePath() async {
    final pickedImg = await imagePicker.pickImage(source: ImageSource.gallery);
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

  String capitalizeAllWord(String value) {
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

  Future<String> inputMenu(String standId, File imgPath) async {
    late String message;
    await FirebaseFirestore.instance
        .collection("Stands")
        .doc(standId)
        .collection("Menus")
        .add({
      "image": "placeholder",
      "name": capitalizeAllWord(tName.text.toString()),
      "price": int.parse(tPrice.text),
      "total": int.parse(tTotal.text),
    }).then((res) async {
      await fileUpload(imgPath, standId, res.id).then((url) async {
        await FirebaseFirestore.instance
            .collection("Stands")
            .doc(standId)
            .collection("Menus")
            .doc(res.id)
            .update({"image": url});
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
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text("Input Menu"),
        backgroundColor: Colors.red[700],
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.4),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Center(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      IconButton(
                          onPressed: () => getImagePath(),
                          icon: const Icon(Icons.image)),
                      (image != null)
                          ? Container(
                              margin: EdgeInsets.only(
                                bottom: MediaQuery.of(context).size.height / 20,
                              ),
                              child: Image(
                                  height:
                                      MediaQuery.of(context).size.height / 5,
                                  width: MediaQuery.of(context).size.height,
                                  image: FileImage(image!)),
                            )
                          : const Text("Image is Empty"),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8, top: 50),
                        child: TextField(
                          controller: tName,
                          decoration: const InputDecoration(
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(10),
                              ),
                              borderSide: BorderSide(
                                color: Colors.transparent,
                              ),
                            ),
                            border: InputBorder.none,
                            enabled: true,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(10),
                              ),
                              borderSide: BorderSide(
                                color: Colors.transparent,
                              ),
                            ),
                            fillColor: Colors.black12,
                            filled: true,
                            hintStyle: TextStyle(color: Colors.black),
                            floatingLabelStyle: TextStyle(color: Colors.black),
                            prefixIcon: Padding(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: Icon(Icons.food_bank_outlined,
                                  color: Colors.black),
                            ),
                            hintText: "Nama Menu Anda",
                            labelText: "Nama Menu",
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: TextField(
                          keyboardType: TextInputType.number,
                          controller: tPrice,
                          decoration: const InputDecoration(
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.transparent,
                              ),
                              borderRadius: BorderRadius.all(
                                Radius.circular(10),
                              ),
                            ),
                            border: InputBorder.none,
                            enabled: true,
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.transparent,
                              ),
                              borderRadius: BorderRadius.all(
                                Radius.circular(10),
                              ),
                            ),
                            fillColor: Colors.black12,
                            filled: true,
                            hintStyle: TextStyle(color: Colors.black),
                            floatingLabelStyle: TextStyle(color: Colors.black),
                            prefixIcon: Padding(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: Icon(Icons.price_change_outlined,
                                  color: Colors.black),
                            ),
                            hintText: "Harga Menu Anda",
                            labelText: "Harga Menu",
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8, bottom: 50),
                        child: TextField(
                          style: TextStyle(color: Colors.black),
                          keyboardType: TextInputType.number,
                          controller: tTotal,
                          decoration: const InputDecoration(
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(10),
                              ),
                              borderSide: BorderSide(
                                color: Colors.transparent,
                              ),
                            ),
                            border: InputBorder.none,
                            enabled: true,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(10),
                              ),
                              borderSide: BorderSide(
                                color: Colors.transparent,
                              ),
                            ),
                            fillColor: Colors.black12,
                            filled: true,
                            hintStyle: TextStyle(color: Colors.black),
                            floatingLabelStyle: TextStyle(color: Colors.black),
                            prefixIcon: Padding(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: Icon(Icons.functions_outlined,
                                  color: Colors.black),
                            ),
                            hintText: "Total Prosi Yang Anda Jual",
                            labelText: "Total Menu",
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          if (tName.text.isNotEmpty &&
                              tPrice.text.isNotEmpty &&
                              tTotal.text.isNotEmpty &&
                              image != null) {
                            inputMenu(standId, image!).then((msg) {
                              var snackBar = SnackBar(content: Text(msg));
                              if (msg == "Menu Berhasil di Tambahkan") {
                                Navigator.pop(context, msg);
                              } else {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(snackBar);
                              }
                            });
                          } else {
                            var snackBar = SnackBar(
                                content:
                                    Text("Tolong Masukkan Data Dengan Benar"));
                            ScaffoldMessenger.of(context)
                                .showSnackBar(snackBar);
                          }
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            width: MediaQuery.of(context).size.width / 4,
                            height: MediaQuery.of(context).size.height / 18,
                            color: Colors.red[700],
                            child: Center(
                              child: const Text(
                                "Input Menu",
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
