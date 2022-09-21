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

  final ImagePicker imagePicker = ImagePicker();
  File? image;
  String oldImage = "";
  late String oldImgName;

  Future getImagePath() async {
    final pickedImg = await imagePicker.pickImage(source: ImageSource.gallery);
    print("image name : ${pickedImg!.name}");
    print("image path : ${pickedImg!.path}");
    setState(() {
      image = File(pickedImg!.path);
      oldImage = "";
    });
  }

  Future<String> fileUpload(File imgPath, String standId, String menuName, String oldName) async {
    await deleteFile(standId, oldName);

    final storageRef = FirebaseStorage.instance.ref();

    // rename image name
    final imgRef = storageRef.child("${standId}/${menuName}");
    try {
      await imgRef.putFile(imgPath);
    } on FirebaseException catch (e) {
      print(e);
    }
    return imgRef.getDownloadURL();
  }

  Future deleteFile(String standId, String menuName) async {
    final storageRef = FirebaseStorage.instance.ref();
    
    final imgDelete = storageRef.child("${standId}/${menuName}");
    await imgDelete.delete().then((msg) {
      print("Berhasil");
    }, onError: (e) {
      print("Error ${e}");
    });
  }

  Future getMenuById(String standId, String menuId) async {
    await FirebaseFirestore.instance.collection("Stands").doc(standId).collection("Menus").doc(menuId).get().then((data) {
      var menu = data.data();
      if (menu != null) {
        setState(() {
          tName = TextEditingController(text: menu['name'].toString());
          tPrice = TextEditingController(text: menu['price'].toString());
          oldImage = menu['image'];
          oldImgName = menu['name'];
        });
      }
    });
  }

  Future<String> editMenu(File? image, String standId, String oldImage) async {
    late String message;
    print("image null ?? : ${image}");
    await FirebaseFirestore.instance.collection("Stands").doc(standId).collection("Menus").doc(menuId).update({
      "name" : tName.text,
      "price" : int.parse(tPrice.text),
      "image" : (image != null) ? await fileUpload(image, standId, tName.text ,oldImage) : oldImage,
    }).then((msg) {
      message = "Menu Berhasil di Edit";
    }, onError: (e) {
      message = "Terjadi Error : ${e}";
    });
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
      appBar: AppBar(
        title: const Text("Edit Menu"),
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
                      CircularProgressIndicator()
                    : Image(
                      height: MediaQuery.of(context).size.height/5 ,
                      width: MediaQuery.of(context).size.height ,
                      image: NetworkImage(oldImage)),
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
                        onPressed: () {
                          editMenu(img, standId, oldImgName).then((msg) {
                            var snackBar = SnackBar(content: Text(msg));
                            if (msg == "Menu Berhasil di Edit") {
                              Navigator.pop(context, msg);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(snackBar);
                            }
                          });
                        },
                        child: const Text("Edit Menu")
                    )
                  ],
                ))
          ],
        ),
      ),
    );
  }
}