import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class SellerHistory extends StatefulWidget {
  final String standId;
  SellerHistory({required this.standId});

  @override
  _SellerHistory createState() => _SellerHistory(standId: standId);
}

class _SellerHistory extends State<SellerHistory> {
  final String standId;
  _SellerHistory({required this.standId});

  Future<QuerySnapshot> getHistory() async {
    return FirebaseFirestore.instance.collection("Stands").doc(standId).collection("History").orderBy('completeAt', descending: true).get();
  }

  String formatTime(Timestamp time) {
    var dateTime = DateTime.parse(time.toDate().toString());
    return DateFormat.yMMMMEEEEd().format(dateTime).toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red[700],
        title: Text("History"),
      ),
      body: FutureBuilder(
          future: getHistory(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text("Terjadi Kesalahan ${snapshot.error}"),
              );
            } else if (snapshot.hasData) {
              return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot historyDoc = snapshot.data!.docs[index];
                  return Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        borderRadius:
                        const BorderRadius.all(Radius.circular(12)),
                      ),
                      child: SizedBox(
                          height: 80,
                          child: Center(
                              child: ListTile(
                                leading: const Icon(Icons.food_bank),
                                title: Text(historyDoc['menuName']),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(historyDoc['userName']),
                                    Text("Total : ${historyDoc['menuTotal'].toString()}"),
                                    Text(formatTime(historyDoc['completeAt'])),
                                  ],
                                ),
                              )
                          )
                      )
                  );
                },);
            } else {
              return const Center(
                child: Text("History Anda Kosong"),
              );
            }
          },),
    );
  }
}
