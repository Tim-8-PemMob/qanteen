import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:paginate_firestore/paginate_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class UserHistory extends StatefulWidget {
  @override
  _UserHistory createState() => _UserHistory();
}

class _UserHistory extends State<UserHistory> {

  String userUid = "";

  Future<void> getUserUid() async {
    final pref = await SharedPreferences.getInstance();
    setState(() {
      userUid = pref.getString("userUid")!;
    });
  }

  String formatTime(Timestamp time) {
    var dateTime = DateTime.parse(time.toDate().toString());
    return DateFormat.yMMMMEEEEd().format(dateTime).toString();
  }

  @override
  void initState() {
    getUserUid();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.only(top: 50),
        child: (userUid != "")? Scrollbar(
          child: PaginateFirestore(
            query: FirebaseFirestore.instance.collection("Users").doc(userUid).collection("History").orderBy('completeAt', descending: true),
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
                                Text(snapshot[index]['standName']),
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
        ) : const  Center(
          child: CircularProgressIndicator(),
        ),
    );
  }
}
