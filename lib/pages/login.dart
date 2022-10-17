import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qanteen/pages/addStand.dart';
import 'package:qanteen/pages/index.dart';
import 'package:qanteen/pages/signup.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../home/home.dart';

Future<dynamic> signIn(String email, String password) async {
  final prefs = await SharedPreferences.getInstance();
  try {
    UserCredential user = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
    final userData = await FirebaseFirestore.instance.collection("Users").doc(user.user!.uid).get();
    var data = jsonDecode(jsonEncode(userData.data()));
    var logedUser = user.user;
    if (logedUser != null) await prefs.setString("userUid", logedUser.uid);
    return data;
  } catch (e) {
    print(e);
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPage createState() => _LoginPage();
}

class _LoginPage extends State<LoginPage> {

  TextEditingController tEmail = TextEditingController(text: "");
  TextEditingController tPassword = TextEditingController(text: "");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios),
          iconSize: 20,
          color: Colors.black,
        ),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Text(
                      "Login",
                      style:
                          TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      "Masuk ke akun anda",
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    children: [
                      inputFile(label: "Email", textEditingController: tEmail),
                      inputFile(label: "Password", textEditingController: tPassword ,obscureText: true)
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  child: Container(
                    padding: EdgeInsets.only(top: 2, left: 3),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      border: Border(
                        bottom: BorderSide(color: Colors.black),
                        top: BorderSide(color: Colors.black),
                        left: BorderSide(color: Colors.black),
                        right: BorderSide(color: Colors.black),
                      ),
                    ),
                    child: MaterialButton(
                      minWidth: double.infinity,
                      height: 60,
                      onPressed: () {
                        signIn(tEmail.text, tPassword.text).then((res) {
                          if (res != null) {
                            if (res['role'] == "user") {
                              // Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => Index()), (Route<dynamic> route) => false);
                              Navigator.push(context, MaterialPageRoute(builder: (context) => home()));
                            } else if (res['role'] == 'seller') {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => AddStand()));
                            }
                          } else {
                            var snackBar = SnackBar(content: Text("Mohon Periksa Lagi User dan Email Anda"));
                            ScaffoldMessenger.of(context).showSnackBar(snackBar);
                          }
                        });
                      },
                      color: Color(0xff0095FF),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Text(
                        "Login",
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                            color: Colors.white),
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Belum punya akun?"),
                    GestureDetector(
                      child: Text(
                        " Daftar",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SignUpPage()));
                      },
                    )
                  ],
                ),
                Container(
                  padding: EdgeInsets.only(top: 100),
                  height: 200,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage("assets/20.jpg"),
                          fit: BoxFit.fitHeight)),
                )
              ],
            ))
          ],
        ),
      ),
    );
  }
}

Widget inputFile({label, obscureText = false, required TextEditingController textEditingController}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Text(
        label,
        style: TextStyle(
            fontSize: 15, fontWeight: FontWeight.w400, color: Colors.black87),
      ),
      SizedBox(
        height: 5,
      ),
      TextField(
        controller: textEditingController,
        obscureText: obscureText,
        decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
            border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.shade400))),
      ),
      SizedBox(
        height: 10,
      )
    ],
  );
}
