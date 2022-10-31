import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_file/open_file.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pf;
import 'package:qanteen/model/nota_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';

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

    await FirebaseFirestore.instance
        .collection("Users")
        .doc(userUid)
        .collection("Orders")
        .where('timeOrder', isEqualTo: timeOrder)
        .get()
        .then((data) async {
      for (var doc in data.docs) {
        await FirebaseFirestore.instance
            .doc(doc['refOrder'].path)
            .get()
            .then((refData) {
          NotaModel notaModel = NotaModel(
              userName: refData.data()!['userName'],
              stand: refData.data()!['standName'],
              menu: refData.data()!['menuName'],
              hargaMenu: refData.data()!['menuPrice'],
              totalBeli: refData.data()!['total'],
              totalHarga:
                  refData.data()!['menuPrice'] * refData.data()!['total']);
          listData.add(notaModel);
        });
      }
    });
    return listData;
  }

  void GeneratePDF() async {
    // final font = await rootBundle.load("assets/open-sans.ttf");
    // final ttf = pf.Font.ttf(font);
    var a = getDetailOrder(timeOrder).then((value) => value);

    final invoice = pf.Document();
    invoice.addPage(pf.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pf.Context context) {
          return pf.Column(
            crossAxisAlignment: pf.CrossAxisAlignment.start,
            children: [
              pf.Text("Struk Anda"),
              pf.SizedBox(height: 0.8 * PdfPageFormat.cm),
              pf.Text("Nama Pembeli : $a"),
              // pf.Text("Menu ${snapshot.data![0].menu}")
            ],
          );
        }));

    // simpan
    Uint8List struk = await invoice.save();

    // buat file kosong di direktori
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/qanteen_${DateTime.now()}.pdf');

    // timpa file kosong dengan file pdf
    await file.writeAsBytes(struk);

    // open pdf
    await OpenFile.open(file.path);
    // print("berhasil timpa");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Nota"),
          centerTitle: true,
          backgroundColor: Colors.red[700],
          actions: [
            IconButton(
              onPressed: () async {
                // getDetailOrder(timeOrder);
                GeneratePDF();
              },
              icon: Icon(Icons.print_outlined),
            )
          ],
        ),
        body: FutureBuilder(
          future: getDetailOrder(timeOrder),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Center(
                child: ListTile(
                  title: Text("Nama Pembeli : ${snapshot.data![0].userName}"),
                  subtitle: ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          ListTile(
                            title: Text("Menu ${snapshot.data![index].menu}"),
                            subtitle: Column(
                              children: [
                                Text(
                                    "Total Beli : ${snapshot.data![index].totalBeli.toString()}"),
                                Text(
                                    "Total Per Menu : ${snapshot.data![index].totalHarga.toString()}"),
                                Text(
                                    "Total Harga : ${snapshot.data![index].totalHarga * snapshot.data![index].totalBeli}"),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text("Terjadi Error"),
              );
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else {
              return Center(
                child: Text("Empty"),
              );
            }
          },
        ));
  }
}
