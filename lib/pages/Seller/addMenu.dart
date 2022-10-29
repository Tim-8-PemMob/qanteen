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
      appBar: AppBar(
        title: Text("Input Menu"),
        backgroundColor: Colors.redAccent,
      ),
      body: Center(
        child: Row(
          children: [
            Expanded(
                child: Column(
              children: [
                IconButton(
                    onPressed: () => getImagePath(),
                    icon: const Icon(Icons.image)),
                (image != null)
                    ? Image(
                        height: MediaQuery.of(context).size.height / 5,
                        width: MediaQuery.of(context).size.height,
                        image: FileImage(image!))
                    : const Text("Image is Empty"),
                TextField(
                  controller: tName,
                  decoration: const InputDecoration(
                    hintText: "Nama Menu Anda",
                    labelText: "Nama Menu",
                  ),
                ),
                TextField(
                  keyboardType: TextInputType.number,
                  controller: tPrice,
                  decoration: const InputDecoration(
                      hintText: "Harga Menu Anda", labelText: "Harga Menu"),
                ),
                TextField(
                  keyboardType: TextInputType.number,
                  controller: tTotal,
                  decoration: const InputDecoration(
                      hintText: "Total Prosi Yang Anda Jual",
                      labelText: "Total Menu"),
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
                            content: Text("Tolong Masukkan Data Dengan Benar"));
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      }
                    },
                    child: const Text("Input Menu"))
              ],
            ))
          ],
        ),
      ),
    );
  }
}
