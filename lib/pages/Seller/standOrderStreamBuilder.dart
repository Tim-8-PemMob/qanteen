import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class StandOrderStreamBuilder extends StatefulWidget {
  final String standId;
  final String status;
  StandOrderStreamBuilder({required this.standId, required this.status});
  
  @override
  _StandOrderStreamBuilder createState() => _StandOrderStreamBuilder(standId: standId, status: status);
}

class _StandOrderStreamBuilder extends State<StandOrderStreamBuilder>{
  final String standId;
  final String status;
  
  _StandOrderStreamBuilder({required this.standId, required this.status});
  
  Future<void> changeStatus(String orderId, String status) async {
    await FirebaseFirestore.instance
        .collection("Stands")
        .doc(standId)
        .collection("Orders")
        .doc(orderId)
        .update({
      "status": status,
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection("Stands").doc(standId).collection("Orders").where("status", isEqualTo: status).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasData && snapshot.data != null) {
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
                      borderRadius:
                      const BorderRadius.all(Radius.circular(12)),
                    ),
                    child: InkWell(
                        child: SizedBox(
                            height: 100,
                            child: Center(
                                child: ListTile(
                                  leading: const Icon(Icons.restaurant_menu),
                                  title: Text(
                                      "Nama Pemesan : ${data["userName"]}"),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text("Pesanan : ${data['menuName']}"),
                                      Text(
                                          "Harga Menu : ${data['menuPrice']}"), //harga menu atau total harga pesanan ???
                                      Text("Total : ${data['total']}"),
                                      Text(data['status'])
                                    ],
                                  ),
                                  trailing: (data['status'] == "Pending")
                                      ? IconButton(
                                    onPressed: () {
                                      changeStatus(data.id, "Process");
                                    },
                                    icon: const Icon(Icons.check),
                                  )
                                      : (data['status'] == "Process")
                                      ? IconButton(
                                    onPressed: () {
                                      changeStatus(
                                          data.id, "Finished");
                                    },
                                    icon: const Icon(Icons.attach_money),
                                  )
                                      : const Text("Ready"),
                                )))));
              },
            );
        } else if (snapshot.hasError) {
          return const Center(
            child: Text("Terjadi Masalah"),
          );
        } else {
          return const Center(
            child: Text("Order Anda Kosong"),
          );
        }
      },
    );
  }
}
