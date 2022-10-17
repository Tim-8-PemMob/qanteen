import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:qanteen/home/home.dart';
import 'package:qanteen/model/order_model.dart';
import 'package:qanteen/pages/menu.dart';
import 'package:qanteen/model/stand_model.dart';
import 'addStand.dart';

class StandOrder extends StatefulWidget {
  final String standId;
  StandOrder({required this.standId});

  @override
  _StandOrder createState() => _StandOrder(standId: standId);
}

class _StandOrder extends State<StandOrder> {
  final String standId;

  _StandOrder({required this.standId});

  // Future<List<OrderModel>> getOrder(String standId) async {
  //   var orderList = List<OrderModel>.empty(growable: true);
  //   await FirebaseFirestore.instance.collection("Stands").doc(standId).collection("Orders").get().then((data) async {
  //     late String namaMenu, namaPemesan;
  //     late int hargaMenu;
  //
  //     for (var doc in data.docs) {
  //       await FirebaseFirestore.instance.collection("Stands").doc(standId).collection("Menus").doc(doc.data()['menuId']).get().then((data) {
  //         var menu = data.data();
  //         if (menu != null) {
  //           namaMenu = menu['name'];
  //           hargaMenu = menu['price'];
  //         }
  //       });
  //
  //       await FirebaseFirestore.instance.collection("Users").doc(doc.data()['userUid']).get().then((data) {
  //         var user = data.data();
  //         if (user != null) {
  //           namaPemesan = user['name'];
  //         }
  //       });
  //
  //       OrderModel orderModel = OrderModel(id: doc.id, namaMenu: namaMenu, totalPesan: doc.data()['total'], hargaMenu: hargaMenu, userUid: doc.data()['userUid'], namaPemesan: namaPemesan, status: doc.data()['status']);
  //       orderList.add(orderModel);
  //     }
  //   });
  //   return orderList;
  // }

  Future<void> changeStatus(String orderId, String status) async {
    await FirebaseFirestore.instance.collection("Stands").doc(standId).collection("Orders").doc(orderId).update({
      "status" : status,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Stand Makanan"),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection("Stands").doc(standId).collection("Orders").snapshots(),
        builder: (context, snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if(snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                DocumentSnapshot data = snapshot.data!.docs[index];
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
                            height: 100,
                            child: Center (
                                child : ListTile(
                                    leading: const Icon(Icons.restaurant_menu),
                                    title: Text("Nama Pemesan : ${data["userName"]}"),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("Pesanan : ${data['menuName']}"),
                                        Text("Harga Menu : ${data['menuPrice']}"), //harga menu atau total harga pesanan ???
                                        Text("Total : ${data['total']}"),
                                        Text(data['status'])
                                      ],
                                    ),
                                  trailing: IconButton(
                                    onPressed: () {
                                      changeStatus(data.id, "Process");
                                    },
                                    icon: Icon(Icons.check) ,
                                  ),
                                )
                            )
                        )
                    )
                );
              },
            );
          } else if(snapshot.hasError) {
            return Center(
              child: Text("Terjadi Masalah"),
            );
          } else {
            return Center(
              child: Text("Order Anda Kosong"),
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