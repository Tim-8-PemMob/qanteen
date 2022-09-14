import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'menu_model.dart';

class Menu extends StatelessWidget {

  final String standNumb;

  Menu({required this.standNumb});

  Future<List<MenuModel>> dataMenu() async {
    DataSnapshot menuSnap = await FirebaseDatabase.instance.ref().child("Stand/${standNumb}/Menu").get();
    print("Stand numb : ${standNumb}");
    print("List Menu : ${menuSnap.value}");
    var listMenu = List<MenuModel>.empty(growable: true);
    var menu = menuSnap.value;
    print("Data Type : ${menu.runtimeType}");
    var y = jsonDecode(jsonEncode(menu));
    print("length : ${y.length}");

    var data = jsonDecode(jsonEncode(menu));
    print("work ? : ${data["menu-1"]}");
    for(int i = 1; i <= data.length; i++) {
      MenuModel menu = MenuModel(name: data["menu-${i}"]["name"], price: data["menu-${i}"]["price"]);
      listMenu.add(menu);
    }
    // data.forEach((key, data) {
    //   listMenu.add(data);
    // });

    print("listMenu : ${listMenu[0].name}");

    return listMenu;
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Menu"),),
      body: FutureBuilder(
        future: dataMenu(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          } else if (snapshot.hasData) {
            return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  return Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        borderRadius: const BorderRadius.all(Radius.circular(12)),
                      ),
                      child: InkWell(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => Menu(standNumb : "Stand-${index + 1}")));
                          },
                          child: SizedBox (
                              height: 80,
                              child: Center (
                                  child : ListTile(
                                    leading: Icon(Icons.restaurant_menu),
                                    title: Text(snapshot.data![index].name.toString()),
                                    subtitle: Text("Rp. ${snapshot.data![index].price.toString()}"),
                                  )
                              )
                          )
                      )
                  );
                }
            );
          } else {
            return CircularProgressIndicator();
          }
        },
      )
    );
  }
}