import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qanteen/pages/User/detailOrder.dart';

import '../../model/cart_model.dart';

class UserOrder extends StatefulWidget {
  final String userUid;
  UserOrder({required this.userUid});

  @override
  _UserOrder createState() => _UserOrder(userUid: userUid);
}

class _UserOrder extends State<UserOrder> {
  final String userUid;
  _UserOrder({required this.userUid});

  Future<List> getUserOrder() async {
    var map = Map();
    List uniqueTime = [];
    await FirebaseFirestore.instance.collection("Users").doc(userUid).collection("Orders").orderBy('timeOrder', descending: false).get().then((data) {
      // data.docs.map((e) {
      //   if(!map.containsKey(e.data()['timeOrder'])) {
      //     map[e.data()['timeOrder']] = 1;
      //   } else {
      //     map[e.data()['timeOrder']] += 1;
      //   }
      // }).toList();
      for(var doc in data.docs) {
        if(!uniqueTime.contains(doc.data()['timeOrder'])) {
          uniqueTime.add(doc.data()['timeOrder']);
        } else {

        }
      }
      print(uniqueTime);
    });
    // print(map);
    return uniqueTime;
    // return map;
  }

  Future<int> countOrder(Timestamp timeOrder) async {
    QuerySnapshot docSnap = await FirebaseFirestore.instance.collection("Users").doc(userUid).collection("Orders").where('timeOrder', isEqualTo: timeOrder).get();
    List<DocumentSnapshot> orderSnapshot = docSnap.docs;
    print(orderSnapshot.length);
    return orderSnapshot.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Your Order"),
      ),
      body: FutureBuilder(
        future: getUserOrder(),
        builder: (context, snapshot) {
          getUserOrder();
          if(snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if(snapshot.hasError) {
            return Center(
              child: const Text("Error"),
            );
          } else if(snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                // DocumentSnapshot data = snapshot.data!.docs[index];
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
                          Navigator.push(context, MaterialPageRoute(builder: (builder) => DetailOrder(timeOrder: snapshot.data![index])));
                        },
                        child: SizedBox (
                            height: 80,
                            child: Center (
                                child : ListTile(
                                  leading: const Icon(Icons.food_bank),
                                  title: Text("Order ${index + 1}"),
                                  subtitle: FutureBuilder(
                                    future: countOrder(snapshot.data![index]),
                                    builder: (context, order) {
                                      if(order.hasData) {
                                        return Text("Total Menu : ${order.data}");
                                      } else {
                                        return Text("Total Menu : ...");
                                      }
                                    },
                                  )
                                )
                            )
                        )
                    )
                );
              },
            );
          } else {
            return Center(
              child: const Text("Empty"),
            );
          }
        },
      )
    );
  }
}
