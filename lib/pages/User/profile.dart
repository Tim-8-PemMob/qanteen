import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:qanteen/pages/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qanteen/pages/User/home/components/SizeConfig.dart';

class myProfile extends StatefulWidget {
  const myProfile({super.key});

  @override
  State<myProfile> createState() => _myProfileState();
}

class _myProfileState extends State<myProfile> {
  bool isObscurePassword = true;

  TextEditingController tUsername = TextEditingController(text: "");
  TextEditingController tPassword = TextEditingController(text: "");

  Future<Map> getsUserData() async {
    Map mapData = new Map();
    final pref = await SharedPreferences.getInstance();
    final String userUid = pref.getString("userUid")!;
    final FirebaseAuth auth = FirebaseAuth.instance;

    final User user = auth.currentUser!;
    mapData['email'] = user.email;

    await FirebaseFirestore.instance
        .collection("Users")
        .doc(userUid)
        .get()
        .then((value) {
      mapData['username'] = value.data()!['name'];
    });

    return mapData;
  }

  Future<String> updateUserData(String password, String username) async {
    late var message;
    final pref = await SharedPreferences.getInstance();
    final String userUid = pref.getString("userUid")!;

    final User user = FirebaseAuth.instance.currentUser!;
    if(password != "") {
      await user.updatePassword(password).then((value) {
        message = "Data anda berhasil di edit";
      }, onError: (e) {
        message = "Terjadi kesalahan $e";
      });
    }

    if(username != "") {
      await FirebaseFirestore.instance.collection("Users").doc(userUid).update({
        'name' : username,
      }).then((value) {
        message = "Data anda berhasil di edit";
      }, onError: (e) {
        message = "Terjadi kesalahan $e";
      });
    }

    return message;
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  Future<void> deleteFcmToken(String? standId) async {
    final prefs = await SharedPreferences.getInstance();
    final String? userUid = prefs.getString("userUid");

    if (standId != null) {
      await FirebaseFirestore.instance
          .collection("Stands")
          .doc(standId)
          .update({
        'ownerFcmToken': "",
      });
    }

    await FirebaseFirestore.instance.collection("Users").doc(userUid).update({
      'fcmToken': "",
    });
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      // appBar: AppBar(),
      body: Container(
        padding: const EdgeInsets.only(left: 15, top: 50, right: 15),
        child: GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: FutureBuilder(
              future: getsUserData(),
              builder: (context, snapshot) {
                return ListView(
                  children: [
                    Center(
                      child: Stack(
                        children: [
                          Container(
                            width: 130,
                            height: 130,
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 4,
                                color: Colors.white,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  spreadRadius: 2,
                                  blurRadius: 10,
                                  color: Colors.black.withOpacity(0.1),
                                )
                              ],
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: AssetImage("assets/profile.jpg"),
                            ),
                          ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(height: 30),
                    buildTextField(
                        "Username",
                        (snapshot.data != null)
                            ? snapshot.data!['username']
                            : "...",
                        false, tUsername),
                    buildTextField("Password", "********", true, tPassword),
                    SizedBox(
                      height: 30,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            if(tPassword.text != "" || tUsername.text != "") {
                              updateUserData(tPassword.text, tUsername.text).then((msg) {
                                setState(() {
                                  tUsername.text = "";
                                  tPassword.text = "";
                                  Fluttertoast.showToast(msg: msg);
                                });
                              });
                            }
                          },
                          child: Text(
                            "Save Change",
                            style: TextStyle(
                              fontSize: 15,
                              letterSpacing: 2,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 30, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: getProportionateScreenHeight(150),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        showDialog<String>(
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
                            title: const Text('Logout'),
                            content: const Text('Logout ?'),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () => Navigator.pop(context, 'Cancel'),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  deleteFcmToken(null).then((value) {
                                    signOut();
                                    Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => LoginPage()),
                                        (Route<dynamic> route) => false);
                                  });
                                },
                                child: const Text('Logout'),
                              ),
                            ],
                          ),
                        );
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.logout, color: Colors.black, size: 30),
                          Text(
                            "Log Out",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shadowColor: Colors.black,
                        padding:
                            EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ],
                );
              },
            )),
      ),
    );
  }

  Widget buildTextField(String labelText, String placeHolder, bool isPasswordField, TextEditingController? textEditingController) {
    return Padding(
      padding: EdgeInsets.only(bottom: 30),
      child: TextField(
        controller: textEditingController,
        obscureText: isPasswordField ? isObscurePassword : false,
        decoration: InputDecoration(
          suffixIcon: isPasswordField
              ? IconButton(
                  icon: Icon(Icons.remove_red_eye, color: Colors.grey),
                  onPressed: () {
                    setState(() {
                      isObscurePassword = !isObscurePassword;
                    });
                  },
                )
              : null,
          contentPadding: EdgeInsets.only(
            bottom: 5,
          ),
          labelText: labelText,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          hintText: placeHolder,
          hintStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }
}
