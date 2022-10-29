import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qanteen/pages/User/nota.dart';
import 'package:qanteen/pages/User/userOrder.dart';
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

  String capitalizeAllWord(String value) {
    var result = value[0].toUpperCase();
    for (int i = 1; i < value.length; i++) {
      if (value[i - 1] == " ") {
        result = result + value[i].toUpperCase();
      } else {
        result = result + value[i];
      }
    }
    return result;
  }

  Future<QuerySnapshot> getDetailOrder(Timestamp timeOrder) async {
    final prefs = await SharedPreferences.getInstance();
    final String? userUid = prefs.getString("userUid");

    return await FirebaseFirestore.instance
        .collection("Users")
        .doc(userUid)
        .collection("Orders")
        .where('timeOrder', isEqualTo: timeOrder)
        .get();
  }

  Future<void> CompleteOrder(
      String orderId,
      String userName,
      String standId,
      String menuId,
      String namaStand,
      String namaMenu,
      int jumlahMenu,
      int hargaMenu) async {
    final prefs = await SharedPreferences.getInstance();
    final String? userUid = prefs.getString("userUid");

    int complete = 0;
    late int orderTotal;
    late bool isComplete = false;

    await FirebaseFirestore.instance
        .collection("Users")
        .doc(userUid)
        .collection("Orders")
        .doc(orderId)
        .get()
        .then((value) async {
      /*
      * jika semua order dengan timestamp yang sama belum complete maka order tidak akan dihapus dan ubah status order ini menjadi complete
      * */
      await FirebaseFirestore.instance
          .collection("Stands")
          .doc(standId)
          .collection("Orders")
          .doc(orderId)
          .update({
        "status": "Complete",
      });

      await FirebaseFirestore.instance
          .collection("Users")
          .doc(userUid)
          .collection("History")
          .add({
        "standId": standId,
        "menuId": menuId,
        "standName": namaStand,
        "menuName": namaMenu,
        "menuTotal": jumlahMenu,
        "menuPrice": hargaMenu,
        "completeAt": Timestamp.fromDate(DateTime.now()),
      });

      await FirebaseFirestore.instance
          .collection("Stands")
          .doc(standId)
          .collection("History")
          .add({
        "userId": userUid,
        "menuId": menuId,
        "userName": userName,
        "menuName": namaMenu,
        "menuTotal": jumlahMenu,
        "menuPrice": hargaMenu,
        "completeAt": Timestamp.fromDate(DateTime.now()),
      });

      await FirebaseFirestore.instance
          .collection("Users")
          .doc(userUid)
          .collection("Orders")
          .where('timeOrder', isEqualTo: timeOrder)
          .get()
          .then((data) async {
        orderTotal = data.docs.length;
        for (var doc in data.docs) {
          await FirebaseFirestore.instance
              .doc(doc.data()!['refOrder'].path)
              .get()
              .then((value) {
            if (value.data()!['status'] == "Complete") {
              complete += 1;
            }
          });
        }
      });
      if (complete == orderTotal) {
        print("Delete All");
        await FirebaseFirestore.instance
            .collection("Users")
            .doc(userUid)
            .collection("Orders")
            .where('timeOrder', isEqualTo: timeOrder)
            .get()
            .then((data) async {
          for (var doc in data.docs) {
            await FirebaseFirestore.instance
                .collection("Users")
                .doc(userUid)
                .collection("Orders")
                .doc(doc.id)
                .delete();
            await FirebaseFirestore.instance
                .doc(doc.data()!['refOrder'].path)
                .delete();
          }
          Navigator.pop(context);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red[700],
        title: Text("Detail Order"),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (builder) => Nota(timeOrder: timeOrder)));
            },
            icon: Icon(Icons.inventory_outlined),
          )
        ],
      ),
      body: FutureBuilder(
        future: getDetailOrder(timeOrder),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasData && snapshot.data != null) {
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                DocumentSnapshot userOrder = snapshot.data!.docs[index];
                return Card(
                  child: Center(
                      child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .doc(userOrder['refOrder'].path)
                        .snapshots(),
                    builder: (context, AsyncSnapshot details) {
                      if (details.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      } else if (!details.hasData ||
                          details.data == null ||
                          details.data!.data() == null) {
                        return Center(
                          child: Text("..."),
                        );
                      } else {
                        return ListTile(
                          leading: const Icon(Icons.food_bank),
                          title: Text(capitalizeAllWord(
                              details.data!.data()!['menuName'])),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  "Total : ${details.data!.data()!['total'].toString()}"),
                              Text(
                                  "Total Price : ${details.data!.data()!['menuPrice'] * details.data!.data()!['total']}"),
                              Text(
                                  "Stand : ${details.data!.data()!['standName']}"),
                            ],
                          ),
                          trailing: (details.data!.data()!['status'] ==
                                  "Finished")
                              ? IconButton(
                                  onPressed: () {
                                    CompleteOrder(
                                            details.data!.id,
                                            details.data!.data()!['userName'],
                                            details.data!.data()!['standId'],
                                            details.data!.data()!['menuId'],
                                            details.data!.data()!['standName'],
                                            details.data!.data()!['menuName'],
                                            details.data!.data()!['total'],
                                            details.data!.data()!['menuPrice'])
                                        .then((res) {});
                                  },
                                  icon: Icon(
                                    Icons.check_circle_sharp,
                                    color: Colors.green,
                                  ),
                                )
                              : Text(details.data!.data()!['status']),
                        );
                      }
                    },
                  )),
                );
              },
            );
          } else if (snapshot.hasError) {
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
