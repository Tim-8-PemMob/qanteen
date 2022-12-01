import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:qanteen/pages/Admin/editStand.dart';
import 'package:qanteen/model/stand_model.dart';
import 'package:qanteen/pages/login.dart';
import 'addSeller.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

Future<List<StandModel>> getStandFireStore() async {
  var listStand = List<StandModel>.empty(growable: true);
  await FirebaseFirestore.instance.collection("Stands").get().then((data) {
    for (var doc in data.docs) {
      StandModel standModel = StandModel(
          id: doc.id.toString(),
          name: doc.data()["name"],
          image: doc.data()['image']);
      listStand.add(standModel);
    }
  });
  return listStand;
}

Future<void> signOut() async {
  await FirebaseAuth.instance.signOut();
}

Future<String> deleteStandById(String standId) async {
  late String message;
  await FirebaseFirestore.instance
      .collection("Stands")
      .doc(standId)
      .delete()
      .then((res) {
    deleteStandStorage(standId);
    message = "Stand Berhasil Di Hapus";
  }, onError: (e) {
    message = "Terjadi Kesalahan ${e}";
  });
  return message;
}

Future deleteStandStorage(String standId) async {
  await FirebaseStorage.instance.ref("${standId}").listAll().then((value) {
    value.items.forEach((element) {
      print("element : ${element}");
      FirebaseStorage.instance.ref(element.fullPath).delete();
    });
  });
}

class Index extends StatefulWidget {
  @override
  _Index createState() => _Index();
}

class _Index extends State<Index> {

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
    getStandFireStore();
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            showDialog<String>(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                title: const Text('Logout'),
                content: const Text('Logout ?'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.pop(context, 'Cancel'),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                        signOut();
                        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => LoginPage()), (Route<dynamic> route) => false);
                    },
                    child: const Text('Logout'),
                  ),
                ],
              ),
            );
          },
          icon: const Icon(Icons.logout),
        ),
        backgroundColor: Colors.red[700],
        title: const Text("Stand Makanan"),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (builder) => AddSeller()));
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: FutureBuilder(
          future: getStandFireStore(),
          builder: (context, snapshot) {
            var data = snapshot.data;
            if (snapshot.hasError) {
              return Text(snapshot.error.toString());
            } else if (data != null && data.isNotEmpty) {
              // reference();
              // addMenu();
              return SmartRefresher (
                  onRefresh: _onRefresh,
                  enablePullDown: true,
                  controller: _refreshController,
                  header: WaterDropHeader(),
                  child : ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {
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
                                height: 80,
                                child: Center(
                                    child: ListTile(
                                      leading: const Icon(Icons.food_bank),
                                      title: Text(data[index].name.toString()),
                                      trailing: PopupMenuButton<int>(
                                          onSelected: (value) async {
                                            if (value == 1) {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (builder) => EditStand(
                                                          standId: data[index]
                                                              .id))).then((msg) =>
                                                  setState(() {
                                                    var snackBar =
                                                    SnackBar(content: Text(msg));
                                                    ScaffoldMessenger.of(context)
                                                        .showSnackBar(snackBar);
                                                  }));
                                            } else if (value == 2) {
                                              showDialog<String>(
                                                context: context,
                                                builder: (BuildContext context) => AlertDialog(
                                                  title: const Text('Delete'),
                                                  content: const Text('Delete ?'),
                                                  actions: <Widget>[
                                                    TextButton(
                                                      onPressed: () => Navigator.pop(context, 'Cancel'),
                                                      child: const Text('Cancel'),
                                                    ),
                                                    TextButton(
                                                      onPressed: () {
                                                        deleteStandById(data[index].id)
                                                            .then((msg) {
                                                          setState(() {
                                                            var snackBar =
                                                            SnackBar(content: Text(msg));
                                                            ScaffoldMessenger.of(context)
                                                                .showSnackBar(snackBar);
                                                          });
                                                        });
                                                        Navigator.pop(context, 'Cancel');
                                                      },
                                                      child: const Text('Delete'),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            }
                                          },
                                          itemBuilder: (BuildContext context) =>
                                          <PopupMenuEntry<int>>[
                                            const PopupMenuItem<int>(
                                                value: 1,
                                                child: const Text("Edit")),
                                            const PopupMenuItem<int>(
                                                value: 2,
                                                child: const Text("Delete")),
                                          ]),
                                    )))));
                  }));
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else {
              return const Center(child: Text("Stands Makanan Kosong"));
            }
          },
        ),
    );
  }
}
