import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:qanteen/pages/login.dart';

Future<String> signUp(String name, String email, String password, String confirmPassword) async {
  final fcmToken = await FirebaseMessaging.instance.getToken();
  late UserCredential user;
  late String message;
  if (name == "" || email == "" || password == "" || confirmPassword == "") {
    message = "Input tidak boleh kosong";
  } else {
    if (password == confirmPassword) {
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password)
          .then((res) async {
        user = res;
        message = "Register Complete";
        await FirebaseFirestore.instance
            .collection("Users")
            .doc(user.user!.uid)
            .set({
          "name": name,
          "role": "user",
          'fcmToken': fcmToken,
        });
      }, onError: (e) {
        message = e.message.toString();
      });
    } else {
      message = "Periksa lagi password anda";
    }
  }
  return message;
}

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPage createState() => _SignUpPage();
}

class _SignUpPage extends State<SignUpPage> {
  TextEditingController tName = TextEditingController(text: "");
  TextEditingController tEmail = TextEditingController(text: "");
  TextEditingController tPassword = TextEditingController(text: "");
  TextEditingController tConfirm = TextEditingController(text: "");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
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
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 40),
          height: MediaQuery.of(context).size.height - 50,
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  Text(
                    "Daftar",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    "Buat Akun anda, gratis",
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
              Column(
                children: <Widget>[
                  inputFile(
                      label: "Nama Lengkap", textEditingController: tName),
                  inputFile(label: "Email", textEditingController: tEmail),
                  inputFile(
                      label: "Password",
                      textEditingController: tPassword,
                      obscureText: true),
                  inputFile(
                      label: "Konfirmasi Password",
                      textEditingController: tConfirm,
                      obscureText: true),
                ],
              ),
              Container(
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
                    signUp(tName.text, tEmail.text, tPassword.text,
                            tConfirm.text)
                        .then((msg) {
                      Fluttertoast.showToast(msg: msg);
                    });
                  },
                  color: Colors.red[700],
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Text(
                    "Daftar",
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                        color: Colors.white),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text("Sudah punya akun?"),
                  GestureDetector(
                    child: Text(
                      " Login",
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                    ),
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => LoginPage()));
                    },
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

Widget inputFile(
    {label,
    obscureText = false,
    required TextEditingController textEditingController}) {
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
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(10),
            ),
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(10),
            ),
          ),
          border: InputBorder.none,
          enabled: true,
        ),
      ),
      SizedBox(
        height: 10,
      )
    ],
  );
}
