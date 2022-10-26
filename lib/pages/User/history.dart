import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class History extends StatefulWidget {
  @override
  _History createState() => _History();
}

class _History extends State<History> {

  Future<QuerySnapshot> getHistory() async {
    final pref = await SharedPreferences.getInstance();
    final String userUid = pref.getString("userUid")!;

    return FirebaseFirestore.instance.collection("Users").doc(userUid).collection("History").orderBy('completeAt', descending: true).get();
  }

  String formatTime(Timestamp time) {
    var dateTime = DateTime.parse(time.toDate().toString());
    return DateFormat.yMMMMEEEEd().format(dateTime).toString();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.only(top: 50),
        child: FutureBuilder(
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
                                    Text(historyDoc['standName']),
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
