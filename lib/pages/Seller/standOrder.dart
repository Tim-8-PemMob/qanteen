import 'package:flutter/material.dart';
import 'package:qanteen/pages/Seller/standOrderStreamBuilder.dart';

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  void dispose() {
    _tabController.dispose();
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
