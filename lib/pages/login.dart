import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:qanteen/pages/Seller/sellerMenu.dart';
import 'package:qanteen/pages/User/home/home.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qanteen/pages/Admin/index.dart';
import 'package:qanteen/pages/signup.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:input_history_text_field/input_history_text_field.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPage createState() => _LoginPage();
}

class _LoginPage extends State<LoginPage> {
  TextEditingController tEmail = TextEditingController(text: "");
  TextEditingController tPassword = TextEditingController(text: "");

  late String standId, userUid;
  Future<Map> signIn(String email, String password) async {
    late String message;
    Map resMap = new Map();
    if(email == "" || password == "") {
      message = "Input tidak boleh kosong";
      resMap['res'] = message;
    } else {
      UserCredential? user;
      final prefs = await SharedPreferences.getInstance();
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password).then((res) {
        user = res;
        message = 'Login complete';
      }, onError: (e) {
        message = e.message.toString();
      });
      if (user != null) {
        final userData = await FirebaseFirestore.instance.collection("Users").doc(user!.user!.uid).get();
        var data = jsonDecode(jsonEncode(userData.data()));
        var logedUser = user!.user;
        if (logedUser != null) {
          userUid = user!.user!.uid;
          await addFcmToken(data['role'], data['standId'], userUid);
          await prefs.setString("userUid", logedUser.uid);
        };
        if (data['role'] == 'seller') standId = data['standId'];
        resMap['data'] = data;
      }
      resMap['res'] = message;
    }
      return resMap;
  }

  Future<void> addFcmToken(String role, String? standId, String userUid) async {
    final fcmToken = await FirebaseMessaging.instance.getToken();
    print('fcm token = $fcmToken');

    await FirebaseFirestore.instance.collection("Users").doc(userUid).update({
      'fcmToken': fcmToken,
    });

    if(role == 'seller') {
      var standData = await FirebaseFirestore.instance.collection("Stands").doc(standId);
      if (standData != null) {
        standData.update({
          'ownerFcmToken' : fcmToken,
        });
      }
    }

    FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) {
      // TODO: If necessary send token to application server.

      // Note: This callback is fired at each app startup and whenever a new
      // token is generated.
    }).onError((err) {
      // Error getting token.
    });
  }

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
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    children: [
                      inputFile(label: "Email", textEditingController: tEmail),
                      inputFile(
                          label: "Password",
                          textEditingController: tPassword,
                          obscureText: true)
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Container(
                    padding: const EdgeInsets.only(top: 2, left: 3),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      border: const Border(
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
                        FocusManager.instance.primaryFocus?.unfocus();
                        signIn(tEmail.text, tPassword.text).then((res) {
                          if (res['data'] != null) {
                            if (res['data']['role'] == "user") {
                              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => home(userUid: userUid)), (Route<dynamic> route) => false);
                            } else if (res['data']['role'] == 'seller') {
                              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => SellerMenu(standId: standId)), (Route<dynamic> route) => false);
                            } else if(res['data']['role'] == 'admin') {
                              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => Index()), (Route<dynamic> route) => false);
                            }
                          } else {
                            Fluttertoast.showToast(msg: res['res']);
                          }
                        });
                      },
                      color: Colors.red[700],
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: const Text(
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
                    const Text("Belum punya akun?"),
                    GestureDetector(
                      child: const Text(
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
