import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

TextEditingController tName = TextEditingController(text: "");

// error : jika menghapus data di tengah maka saat menginput data berikutnya akan mengganti data yang terakhir di inputkan
Future<String> addStand() async {
  late String message;
  await FirebaseFirestore.instance.collection("Stands").add({
    "name" : tName.text.toString()
  }).then((msg) {
    message = "Stand Anda Berhasil Ditambahkan";
  }, onError: (e) {
    message = "Terjadi Error : ${e}";
  });
  return message;
}

class AddStand extends StatefulWidget {
  @override
  _AddStand createState() => _AddStand();
}

class _AddStand extends State<AddStand> {

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
                    TextField(
                      controller: tName,
                      decoration: InputDecoration(
                          hintText: "Nama Stand",
                      ),
                    ),
                    TextButton(
                        onPressed: () {
                          if (tName.text.isNotEmpty) {
                            addStand().then((msg) {
                              var snackBar = SnackBar(content: Text(msg));
                              if (msg == "Stand Anda Berhasil Ditambahkan") {
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