import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditMenu extends StatefulWidget {
  final String standId, menuId;

  EditMenu({required this.standId, required this.menuId});

  @override
  _EditMenu createState() => _EditMenu(standId: standId, menuId: menuId);
}

class _EditMenu extends State<EditMenu> {
  final String standId, menuId;

  _EditMenu({required this.standId, required this.menuId});

  TextEditingController tName = TextEditingController(text: "");
  TextEditingController tPrice = TextEditingController(text: "");
  TextEditingController tTotal = TextEditingController(text: "");

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

  Future<String> fileUpload(File imgPath, String standId, String menuId) async {
    await deleteFile(standId, menuId);

    final storageRef = FirebaseStorage.instance.ref();

    // rename image name
    final imgRef = storageRef.child("${standId}/${menuId}");
    try {
      await imgRef.putFile(imgPath);
    } on FirebaseException catch (e) {
      print(e);
    }
    return imgRef.getDownloadURL();
  }

  Future deleteFile(String standId, String menuId) async {
    final storageRef = FirebaseStorage.instance.ref();

    final imgDelete = storageRef.child("${standId}/${menuId}");
    await imgDelete.delete().then((msg) {
      print("Berhasil");
    }, onError: (e) {
      print("Error ${e}");
    });
  }

  // jika ganti nama tanpa ganti gambar nantinya saat ganti gambar maka gambar lama tidak terhapus
  Future getMenuById(String standId, String menuId) async {
    await FirebaseFirestore.instance
        .collection("Stands")
        .doc(standId)
        .collection("Menus")
        .doc(menuId)
        .get()
        .then((data) {
      var menu = data.data();
      if (menu != null) {
        setState(() {
          tName = TextEditingController(text: menu['name'].toString());
          tPrice = TextEditingController(text: menu['price'].toString());
          tTotal = TextEditingController(text: menu['total'].toString());
          oldImage = menu['image'];
        });
      }
    });
  }

  Future<String> editMenu(
      File? image, String standId, String oldImageURL, String menuId) async {
    // jika gambar di ganti : upload gambar terlebih dahulu lalu ambil urlnya dan dimasukkan ke dalam db
    late String message;
    print("image null ?? : ${image}");
    print("old image : ${oldImage}");

    if (oldImageURL == "") {
      await fileUpload(image!, standId, menuId).then((url) {
        FirebaseFirestore.instance
            .collection("Stands")
            .doc(standId)
            .collection("Menus")
            .doc(menuId)
            .update({
          "name": tName.text,
          "price": int.parse(tPrice.text),
          "total": int.parse(tTotal.text),
          "image": url,
        });
        message = "Menu Berhasil di Edit";
      }, onError: (e) {
        message = "Terjadi Error : ${e}";
      });
    } else {
      await FirebaseFirestore.instance
          .collection("Stands")
          .doc(standId)
          .collection("Menus")
          .doc(menuId)
          .update({
        "name": tName.text,
        "price": int.parse(tPrice.text),
        "total": int.parse(tTotal.text),
        "image": oldImageURL,
      }).then((msg) {
        message = "Menu Berhasil di Edit";
      }, onError: (e) {
        message = "Terjadi Error : ${e}";
      });
    }
    return message;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getMenuById(standId, menuId);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    var img = image;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text("Edit Menu"),
        backgroundColor: Colors.red[700],
      ),
      body: SingleChildScrollView(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.4),
        scrollDirection: Axis.vertical,
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
                            ? CircularProgressIndicator()
                            : Container(
                                margin: EdgeInsets.only(
                                    bottom: MediaQuery.of(context).size.height /
                                        20),
                                child: Image(
                                  height:
                                      MediaQuery.of(context).size.height / 5,
                                  width: MediaQuery.of(context).size.height,
                                  image: NetworkImage(oldImage),
                                ),
                              ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: TextField(
                        controller: tName,
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
                          hintText: "Nama Baru Menu",
                          labelText: "Nama Menu",
                        ),
                      ),
                    ),
                    // TextField(
                    //   controller: tName,
                    //   decoration: const InputDecoration(
                    //       hintText: "Nama Baru Menu", labelText: "Nama Menu"),
                    // ),
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
                          hintText: "Harga Baru Menu",
                          labelText: "Harga Menu",
                        ),
                      ),
                    ),
                    // TextField(
                    //   keyboardType: TextInputType.number,
                    //   controller: tPrice,
                    //   decoration: const InputDecoration(
                    //       hintText: "Harga Baru Menu", labelText: "Harga Menu"),
                    // ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 50),
                      child: TextField(
                        keyboardType: TextInputType.number,
                        controller: tTotal,
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
                          hintText: "Total Porsi Menu",
                          labelText: "Total Menu",
                        ),
                      ),
                    ),
                    // TextField(
                    //   keyboardType: TextInputType.number,
                    //   controller: tTotal,
                    //   decoration: const InputDecoration(
                    //       hintText: "Total Porsi Menu", labelText: "Total Menu"),
                    // ),
                    TextButton(
                      onPressed: () {
                        editMenu(img, standId, oldImage, menuId).then((msg) {
                          var snackBar = SnackBar(content: Text(msg));
                          if (msg == "Menu Berhasil di Edit") {
                            Navigator.pop(context, msg);
                          } else {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(snackBar);
                          }
                        });
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
