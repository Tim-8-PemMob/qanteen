import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:qanteen/menu.dart';
import 'package:qanteen/model/stand_model.dart';
import 'addStand.dart';


Future<List<StandModel>> getStandFireStore() async {
  var listStand = List<StandModel>.empty(growable: true);
  await FirebaseFirestore.instance.collection("Stands").get().then((data) {
    for (var doc in data.docs) {
      StandModel standModel = StandModel(id: doc.id.toString(), name: doc.data()["name"]);
      listStand.add(standModel);
    }
  });
  return listStand;
}

class Index extends StatefulWidget {
  @override
  _Index createState() => _Index();
}

class _Index extends State<Index> {

  @override
  Widget build(BuildContext context) {
    getStandFireStore();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Stand Makanan"),
      ),
      body: FutureBuilder(
        future: getStandFireStore(),
        builder: (context, snapshot) {
          var data = snapshot.data;
          if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          } else if (data != null) {
            // reference();
            // addMenu();
            return ListView.builder(
                itemCount: data.length,
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
                            Navigator.push(context, MaterialPageRoute(builder: (context) => Menu(standId : data[index].id)));
                          },
                          child: SizedBox (
                              height: 80,
                              child: Center (
                                  child : ListTile(
                                    leading: const Icon(Icons.food_bank),
                                    title: Text("Stand : ${data[index].name.toString()}"),
                                  )
                              )
                          )
                      )
                  );
            }
            );
          } else {
            return const Center(
                child: CircularProgressIndicator()
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
          onPressed:() {
            Navigator.push(context, MaterialPageRoute(builder: (context) => AddStand())).then((msg) => setState(() {
              var snackBar = SnackBar(content: Text(msg));
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            }));
          },
        child: const Icon(Icons.add),
      ),
    );
  }
}