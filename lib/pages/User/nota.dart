import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pf;
import 'package:qanteen/model/nota_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Nota extends StatefulWidget {
  final Timestamp timeOrder;
  Nota({required this.timeOrder});

  @override
  _Nota createState() => _Nota(timeOrder: timeOrder);
}

class _Nota extends State<Nota> {
  final Timestamp timeOrder;
  _Nota({required this.timeOrder});

  int hargaAkhir = 0;

  Future<List<NotaModel>> getDetailOrder(Timestamp timeOrder) async {
    var listData = List<NotaModel>.empty(growable: true);
    final prefs = await SharedPreferences.getInstance();
    final String? userUid = prefs.getString("userUid");

    await FirebaseFirestore.instance.collection("Users").doc(userUid).collection("Orders").where('timeOrder', isEqualTo: timeOrder).get().then((data) async {
      for(var doc in data.docs) {
        await FirebaseFirestore.instance.doc(doc['refOrder'].path).get().then((refData) {
          NotaModel notaModel = NotaModel(userName: refData.data()!['userName'], stand: refData.data()!['standName'], menu: refData.data()!['menuName'], hargaMenu: refData.data()!['menuPrice'], totalBeli: refData.data()!['total'], totalHarga: refData.data()!['menuPrice'] * refData.data()!['total']);
          listData.add(notaModel);
        });
      }
    });
    return listData;
  }

  void GeneratePDF() {
    final invoice = pf.Document();
    invoice.addPage(pf.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pf.Context context) {
          return pf.Center(
            child: pf.Text("Test PDF"),
          );
        }
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Nota"),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () {
                getDetailOrder(timeOrder);
              },
              icon: Icon(Icons.ac_unit),
          )
        ],
      ),
      body: FutureBuilder(
        future: getDetailOrder(timeOrder),
        builder: (context, snapshot) {
          if(snapshot.hasData) {
            return Center(
              child: ListTile(
                title: Text("Nama Pembeli : ${snapshot.data![0].userName}"),
                subtitle: ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text("Menu ${snapshot.data![index].menu}"),
                      subtitle: Column(
                        children: [
                          Text("Total Beli : ${snapshot.data![index].totalBeli.toString()}"),
                          Text("Total Per Menu : ${snapshot.data![index].totalHarga.toString()}"),
                        ],
                      ),
                    );
                  },
                ),
              ),
            );
          } else if(snapshot.hasError){
            return Center(
              child: Text("Terjadi Error"),
            );
          } else if(snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return Center(
              child: Text("Empty"),
            );
          }
        },
      )
    );
  }
}
