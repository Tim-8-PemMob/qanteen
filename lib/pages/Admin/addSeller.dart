import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../index.dart';

class AddSeller extends StatefulWidget {
  @override
  _AddSeller createState() => _AddSeller();
}

class _AddSeller extends State<AddSeller> {

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
    await FirebaseFirestore.instance.collection("Stands").add({
      "name" : tName.text.toString()
    }).then((res) async {
      await fileUpload(image!, res.id).then((url) async {
        await FirebaseFirestore.instance.collection("Stands").doc(res.id).update({
          "image" : url
        });
      });
      standId = res.id;
    });
    return standId;
  }

  Future<String> addSeller(String name, String email, String password, String confirmPassword) async {
    late String message;
    try {
      if (password == confirmPassword) {
        UserCredential user = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);
        print("data user : ${user}");
        print("data user.user ${user.user}");
        await FirebaseFirestore.instance
            .collection("Users")
            .doc(user.user!.uid)
            .set({
          "name": name,
          "role" : "seller",
          'standId' : await addStand(),
        }).then((value) {
          message = "Email dan Stand berhasil di tambahkan";
        }, onError: (e) {
          message = "Terjadi kesalahan ${e}";
        });
      } else {
        message = "Periksa lagi password anda";
      }
    } catch (e) {
      print(e);
    }
    return message;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
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
                        hintText: "Masukkan Nama Stand",
                        labelText: "Nama Stand",
                      ),
                    ),
                    TextField(
                      controller: tEmail,
                      decoration: const InputDecoration(
                        hintText: "Email Seller",
                        labelText: "Email Seller",
                      ),
                    ),
                    TextField(
                      controller: tPassword,
                      obscureText: true,
                      decoration: const InputDecoration(
                        hintText: "Password",
                        labelText: "Password",
                      ),
                    ),TextField(
                      controller: tConfirmPassword,
                      obscureText: true,
                      decoration: const InputDecoration(
                        hintText: "Confirm Password",
                        labelText: "Confirm Password",
                      ),
                    ),
                    TextButton(
                        onPressed: () {
                          if (tName.text.isNotEmpty && tEmail.text.isNotEmpty && tPassword.text.isNotEmpty && image != null) {
                            addSeller(tName.text, tEmail.text, tPassword.text, tConfirmPassword.text).then((msg) {
                              var snackBar = SnackBar(content: Text(msg));
                              if (msg == "Email dan Stand berhasil di tambahkan") {
                                setState(() {
                                  tName.text = "";
                                  tEmail.text = "";
                                  tPassword.text = "";
                                  tConfirmPassword.text = "";
                                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                });
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