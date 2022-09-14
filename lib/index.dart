import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:qanteen/menu.dart';
import 'package:qanteen/stand_model.dart';


Future<List<StandModel>> getStand() async {
  DataSnapshot standSnap = await FirebaseDatabase.instance.ref().child("Stand").get();
  var listStand = List<StandModel>.empty(growable: true);
  var standDecode = jsonDecode(jsonEncode(standSnap.value));

  print(standDecode["Stand-1"]["name"]);

  for(int i = 1; i <= standDecode.length; i++) {
    StandModel stand = StandModel(name: standDecode["Stand-${i}"]["name"]);
    listStand.add(stand);
  }

  return listStand;
}

void addMenu() async {
  DatabaseReference dataRef = FirebaseDatabase.instance.ref('Menu');
  await dataRef.update({
    "10" : "Ayam Geprek",
  });
}

// Future<DatabaseReference> reference() async {
//   DatabaseReference restoRef = FirebaseDatabase.instance.ref("Menu");
//   restoRef.onValue.listen((DatabaseEvent event) {
//     final data = event.snapshot.value;
//     print("data : " + data.toString());
//     print("new data, data type ${data.runtimeType}");
//   });
//   return restoRef;
// }

class Index extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Stand Makanan"),
      ),
      body: FutureBuilder(
        future: getStand(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          } else if (snapshot.hasData) {
            // reference();
            addMenu();
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
                                    leading: Icon(Icons.food_bank),
                                    title: Text("Stand : ${snapshot.data![index].name.toString()}"),
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