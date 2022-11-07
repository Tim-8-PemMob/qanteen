import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/material.dart';
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

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  Future<void> deleteFcmToken(String? standId) async {
    final prefs = await SharedPreferences.getInstance();
    final String? userUid = prefs.getString("userUid");

    if (standId != null) {
      await FirebaseFirestore.instance.collection("Stands").doc(standId).update({
        'ownerFcmToken' : "",
      });
    }

    await FirebaseFirestore.instance.collection("Users").doc(userUid).update({
      'fcmToken' : "",
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
                                  image: NetworkImage(
                                      'https://images.unsplash.com/photo-1534528741775-53994a69daeb?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=464&q=80')),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border:
                                      Border.all(width: 4, color: Colors.white),
                                  color: Colors.blue),
                              child: IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () {
                                  print("edit");
                                },
                                color: Colors.white,
                                padding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 30),
                    buildTextField(
                        "Username",
                        (snapshot.data != null)
                            ? snapshot.data!['username']
                            : "...",
                        false),
                    buildTextField(
                        "Email",
                        (snapshot.data != null)
                            ? snapshot.data!['email']
                            : "...",
                        false),
                    buildTextField("Password", "********", true),
                    SizedBox(
                      height: 30,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        OutlinedButton(
                          onPressed: () {},
                          child: Text(
                            "Cancel",
                            style: TextStyle(
                                fontSize: 15,
                                letterSpacing: 2,
                                color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 30, vertical: 15),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20))),
                        ),
                        ElevatedButton(
                          onPressed: () {},
                          child: Text(
                            "SAVE",
                            style: TextStyle(
                              fontSize: 15,
                              letterSpacing: 2,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: EdgeInsets.symmetric(
                                horizontal: 30, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: getProportionateScreenHeight(160),
                    ),
                    ElevatedButton(
                      onPressed: () {},
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
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            deleteFcmToken(null).then((value) {
              signOut();
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => LoginPage()), (Route<dynamic> route) => false);
            });
          },
        child: const Icon(Icons.logout),
      ),
    );
  }

  Widget buildTextField(
      String labelText, String placeHolder, bool isPasswordField) {
    return Padding(
      padding: EdgeInsets.only(bottom: 30),
      child: TextField(
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
