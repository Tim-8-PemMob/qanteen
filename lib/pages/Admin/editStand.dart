import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
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
    await FirebaseFirestore.instance
        .collection('Stands')
        .doc(standId)
        .get()
        .then((data) {
      var stand = data.data();
      if (stand != null) {
        setState(() {
          tName = TextEditingController(text: stand['name'].toString());
          oldImage = stand['image'];
        });
      }
    });
  }

  Future<String> editStand(
      File? image, String standId, String oldImageUrl) async {
    late String message;

    if (oldImage == "") {
      await fileUpload(image!, standId).then((url) async {
        await FirebaseFirestore.instance
            .collection("Stands")
            .doc(standId)
            .update({
          "name": tName.text,
          "image": url,
        });
        message = "Stand Berhasil Di Edit";
      }, onError: (e) {
        message = "Terjadi Masalah ${e}";
      });
    } else {
      await FirebaseFirestore.instance
          .collection("Stands")
          .doc(standId)
          .update({
        "name": tName.text,
        "image": oldImageUrl,
      }).then((res) {
        message = "Stand Berhasil Di Edit";
      }, onError: (e) {
        message = "Terjadi Masalah ${e}";
      });
    }
    return message;
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
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.red[700],
        title: const Text("Edit Stands"),
      ),
      body: SingleChildScrollView(
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
                    (oldImage == "" && img != null)
                        ? Container(
                            margin: EdgeInsets.only(
                              bottom: MediaQuery.of(context).size.height / 20,
                            ),
                            child: Image(
                                height: MediaQuery.of(context).size.height / 5,
                                width: MediaQuery.of(context).size.height,
                                image: FileImage(img)),
                          )
                        : (oldImage == "" && img == null)
                            ? const CircularProgressIndicator()
                            : Container(
                                margin: EdgeInsets.only(
                                  bottom:
                                      MediaQuery.of(context).size.height / 20,
                                ),
                                child: Image(
                                    height:
                                        MediaQuery.of(context).size.height / 5,
                                    width: MediaQuery.of(context).size.height,
                                    image: NetworkImage(oldImage)),
                              ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 50, top: 8),
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
                          hintText: "Nama Stand Anda",
                          labelText: "Nama Baru Stand Anda",
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () async =>
                          editStand(img, standId, oldImage).then((msg) {
                        var snackBar = SnackBar(content: Text(msg));
                        if (msg == "Stand Berhasil Di Edit") {
                          // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Menu(standId: standId)));
                          Navigator.pop(context, msg);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        }
                      }),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          width: MediaQuery.of(context).size.width / 4,
                          height: MediaQuery.of(context).size.height / 18,
                          color: Colors.red[700],
                          child: Center(
                            child: const Text(
                              "Simpan Perubahan",
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
