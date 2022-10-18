import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:qanteen/pages/User/nota.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DetailOrder extends StatefulWidget {
  final Timestamp timeOrder;
  DetailOrder({required this.timeOrder});

  @override
  _DetailOrder createState() => _DetailOrder(timeOrder: timeOrder);
}

class _DetailOrder extends State<DetailOrder> {
  final Timestamp timeOrder;
  _DetailOrder({required this.timeOrder});

  Future<QuerySnapshot> getDetailOrder(Timestamp timeOrder) async {
    final prefs = await SharedPreferences.getInstance();
    final String? userUid = prefs.getString("userUid");

    return await FirebaseFirestore.instance.collection("Users").doc(userUid).collection("Orders").where('timeOrder', isEqualTo: timeOrder).get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Detail Order"),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (builder) => Nota(timeOrder: timeOrder)));
              },
              icon: Icon(Icons.inventory_outlined),
          )
        ],
      ),
      body: FutureBuilder(
        future: getDetailOrder(timeOrder),
        builder: (context, snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if(snapshot.hasData) {
              return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot menu = snapshot.data!.docs[index];
                  return Card(
                    child: Center(
                        child : StreamBuilder(
                          stream: FirebaseFirestore.instance.doc(menu['refOrder'].path).snapshots(),
                          builder: (context, details) {
                            if(details.connectionState == ConnectionState.waiting) {
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            } else {
                              return ListTile(
                                leading: const Icon(Icons.food_bank),
                                title: Text(details.data!.data()!['menuName']),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Total : ${details.data!.data()!['total'].toString()}"),
                                    Text("Total Price : ${details.data!.data()!['menuPrice'] * details.data!.data()!['total']}"),
                                    Text("Stand : ${details.data!.data()!['standName']}"),
                                  ],
                                ),
                                trailing: Text(details.data!.data()!['status']),
                              );
                            }
                          },
                        )
                    ),
                  );
                },
              );
          } else if(snapshot.hasError) {
            return Center(
              child: Text("Terjadi error"),
            );
          } else {
            return Center(
              child: Text("Empty"),
            );
          }
        },
      ),
    );
  }
}
