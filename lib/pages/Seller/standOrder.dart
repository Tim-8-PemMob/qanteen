import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:qanteen/api/notification_api.dart';
import 'package:qanteen/model/order_model.dart';
import 'package:qanteen/pages/Seller/standOrderStreamBuilder.dart';
import 'package:qanteen/pages/User/menu.dart';
import 'package:qanteen/model/stand_model.dart';
import '../Admin/addSeller.dart';

class StandOrder extends StatefulWidget {
  final String standId;
  StandOrder({required this.standId});

  @override
  _StandOrder createState() => _StandOrder(standId: standId);
}

class _StandOrder extends State<StandOrder> with TickerProviderStateMixin {
  final String standId;

  _StandOrder({required this.standId});

  late TabController _tabController;
  late final NotificationApi notificationApi;

  StreamController<void> streamController = new StreamController();

  // Stream<void> checkIncomingOrder() async* {
  //   print('stream');
  //   FirebaseFirestore.instance.collection("Stands").doc(standId).collection("Order").where("status", isEqualTo: "Pending").snapshots().listen((event) {
  //     streamController.add(event);
  //   });
  // }

  Stream<void> checkIncomingOrder() async* {
    // FirebaseFirestore.instance.collection("Stands").doc(standId).collection("Order").where("status", isEqualTo: "Pending").snapshots(includeMetadataChanges: true).listen((event) {
    //   print('event');
    //   streamController.add(event);
    //   // if (event.metadata.hasPendingWrites) streamController.add(event);
    // });
    streamController.add(FirebaseFirestore.instance.collection("Stands").doc(standId).collection("Order").where("status", isEqualTo: "Pending").snapshots(includeMetadataChanges: true));
  }

  //TODO: fix stream

  @override
  void initState() {
    super.initState();

    notificationApi = NotificationApi();
    notificationApi.initialize();
    _tabController = TabController(length: 3, vsync: this);

    FirebaseFirestore.instance.collection("Stands").doc(standId).collection("Order").where("status", isEqualTo: "Pending").snapshots(includeMetadataChanges: true).listen((event) {
        print('event');
        // streamController.add(event);
        if (event.metadata.hasPendingWrites) notificationApi.showNotification(id: 0, title: "Incoming Order", body: "New Order Here");
    });

    // stream();
    checkIncomingOrder().listen((event) {
      notificationApi.showNotification(id: 0, title: "Incoming Order", body: "New Order Here");
    }, onDone: () {
      print("Complete");
    }, onError: (e) {
      print('error $e');
    });
  }

  void dispose() {
    _tabController.dispose();
    streamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Order"),
          backgroundColor: Colors.red[700],
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(
                child: Text(
                  "Pesanan Masuk",
                  style: TextStyle(fontWeight: FontWeight.w400, fontSize: 17),
                  textAlign: TextAlign.center,
                ),
              ),
              Tab(
                child: Text(
                  "Sedang diproses",
                  style: TextStyle(fontWeight: FontWeight.w400, fontSize: 17),
                  textAlign: TextAlign.center,
                ),
              ),
              Tab(
                child: Text(
                  "Pesanan Selesai",
                  style: TextStyle(fontWeight: FontWeight.w400, fontSize: 17),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: <Widget>[
            StandOrderStreamBuilder(standId: standId, status: "Pending"),
            StandOrderStreamBuilder(standId: standId, status: "Process"),
            StandOrderStreamBuilder(standId: standId, status: "Finished"),
          ],
        ),
      ),
    );
  }
}
