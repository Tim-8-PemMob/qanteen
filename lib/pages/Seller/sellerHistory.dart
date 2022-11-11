import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:paginate_firestore/paginate_firestore.dart';

class SellerHistory extends StatefulWidget {
  final String standId;
  SellerHistory({required this.standId});

  @override
  _SellerHistory createState() => _SellerHistory(standId: standId);
}

class _SellerHistory extends State<SellerHistory> {
  final String standId;
  _SellerHistory({required this.standId});

  String formatTime(Timestamp time) {
    var dateTime = DateTime.parse(time.toDate().toString());
    return DateFormat.yMMMMEEEEd('id').format(dateTime).toString();
  }

  @override
  void initState() {
    super.initState();
    initializeDateFormatting();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red[700],
        title: Text("History"),
      ),
      body: Scrollbar(
          child: PaginateFirestore(
            query: FirebaseFirestore.instance.collection("Stands").doc(standId).collection("History").orderBy('completeAt', descending: true),
            itemBuilderType: PaginateBuilderType.listView,
            itemBuilder: (context, snapshot, index) {
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
                      height: MediaQuery.of(context).size.height / 9,
                      child: Center(
                          child: ListTile(
                            leading: const Icon(Icons.food_bank),
                            title: Text(snapshot[index]['menuName']),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(snapshot[index]['userName']),
                                Text("Total : ${snapshot[index]['menuTotal'].toString()}"),
                                Text(formatTime(snapshot[index]['completeAt'])),
                              ],
                            ),
                          )
                      )
                  )
              );
            },
          ),
      ),
    );
  }
}
