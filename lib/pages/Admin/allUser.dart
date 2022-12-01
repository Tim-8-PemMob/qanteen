import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:qanteen/pages/Admin/addStand.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class AllUser extends StatefulWidget {
  @override
  _AllUser createState() => _AllUser();
}

class _AllUser extends State<AllUser> {

  Future<QuerySnapshot> getUser() async {
    return await FirebaseFirestore.instance.collection("Users").where('role', isNotEqualTo: 'admin').get();
  }

  Future<bool> isUserHaveNoStand(String standId) async {
    bool isHaveNoStand = true;
    await FirebaseFirestore.instance.collection("Stands").doc(standId).get().then((value) {
      if(value.data() != null) {
        isHaveNoStand = false;
      }
    });
    return isHaveNoStand;
  }

  RefreshController _refreshController =
  RefreshController(initialRefresh: false);

  void _onRefresh() async{
    // await getStandFireStore();
    await Future.delayed(Duration(milliseconds: 500));
    setState(() {

    });
    _refreshController.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All User"),
        backgroundColor: Colors.red[700],
      ),
      body: FutureBuilder(
        future: getUser(),
        builder: (context, snapshot) {
          if(snapshot.hasError) {
            return Center(
              child: Text(snapshot.error.toString()),
            );
          } else if(snapshot.hasData) {
            return SmartRefresher(
              controller: _refreshController,
              enablePullUp: true,
              onRefresh: _onRefresh,
              child: ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  var user = snapshot.data!.docs[index];
                  return Card (
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
                              height: 80,
                              child: Center(
                                  child: ListTile(
                                    leading: const Icon(Icons.people),
                                    title: Text(user['name']),
                                    subtitle: Text(user['role']),
                                    trailing: (user['role'] == "seller")?FutureBuilder(
                                      future: isUserHaveNoStand(user['standId']),
                                      builder: (context, snapshot) {
                                        if(snapshot.hasData) {
                                          if(snapshot.data!) {
                                            return IconButton(
                                              onPressed: () {
                                                Navigator.push(context, MaterialPageRoute(builder: (builder) => AddStand(userUid: user.id)));
                                              },
                                              icon: const Icon(Icons.food_bank),);
                                          } else {
                                            return const Text("");
                                          }
                                        } else {
                                          return const Text("");
                                        }
                                      },
                                    ) : null,
                                  )
                              )
                          )
                      )
                  );
                },
              ),
            );
          } else if(snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return const Center(
              child: Text("Stands Kosong"),
            );
          }
        },
      ),
    );
  }
}
