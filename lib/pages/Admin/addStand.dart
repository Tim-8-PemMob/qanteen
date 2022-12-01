import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class AddStand extends StatefulWidget {
  final String userUid;
  AddStand({required this.userUid});

  @override
  _AddStand createState() => _AddStand(userUid: userUid);
}

class _AddStand extends State<AddStand> {
  final String userUid;
  _AddStand({required this.userUid});

  TextEditingController tName = TextEditingController(text: "");
  TextEditingController tEmail = TextEditingController(text: "");
  TextEditingController tPassword = TextEditingController(text: "");
  TextEditingController tConfirmPassword = TextEditingController(text: "");

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
    late String standId;
    await FirebaseFirestore.instance
        .collection("Stands")
        .add({"name": tName.text.toString()}).then((res) async {
      await fileUpload(image!, res.id).then((url) async {
        await FirebaseFirestore.instance
            .collection("Stands")
            .doc(res.id)
            .update({"image": url});
      });
      standId = res.id;
    });
    return standId;
  }

  Future<String> newStands(String name, String userUid) async {
    late String message;
    try {
      await FirebaseFirestore.instance.collection("Users").doc(userUid).update({
          "name": name,
          "role": "seller",
          'standId': await addStand(),
        }).then((value) {
          message = "Stand Berhasil Ditambahkan";
        }, onError: (e) {
          message = "Terjadi kesalahan ${e}";
        });
    } catch (e) {
      print(e);
    }
    return message;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.red[700],
        title: const Text("Add Stand"),
      ),
      body: SingleChildScrollView(
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
                                height: MediaQuery.of(context).size.height / 5,
                                width: MediaQuery.of(context).size.height,
                                image: FileImage(image!)),
                          )
                        : const Text("Image is Empty"),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
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
                          hintText: "Masukkan Nama Stand",
                          labelText: "Nama Stand",
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        if (tName.text.isNotEmpty && image != null) {
                          newStands(tName.text, userUid).then((msg) {
                            if (msg == "Stand Berhasil Ditambahkan") {
                              setState(() {
                                tName.text = "";
                                Fluttertoast.showToast(msg: msg);
                              });
                            }
                          });
                        } else {
                          Fluttertoast.showToast(msg: "Tolong Masukkan Data Dengan Benar");
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
                              "Input Stand",
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
