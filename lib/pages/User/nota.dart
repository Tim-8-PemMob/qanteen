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
import 'package:qanteen/pages/User/nota/folder_clipper.dart';
import 'package:qanteen/pages/User/nota/invoice_clipper.dart';
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

  void GeneratePDF(String pembeli, String menu) async {
    // final font = await rootBundle.load("assets/open-sans.ttf");
    // final ttf = pf.Font.ttf(font);
    // List<String> detailOrder;
    // var a = await getDetailOrder(timeOrder);
    // final Future<List<dynamic>> futureList = getDetailOrder(timeOrder);
    // final list = await futureList;

    final invoice = pf.Document();
    invoice.addPage(pf.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pf.Context context) {
          return pf.Column(
            crossAxisAlignment: pf.CrossAxisAlignment.start,
            children: [
              pf.Text("Struk Anda"),
              pf.SizedBox(height: 0.8 * PdfPageFormat.cm),
              pf.Text("Nama Pembeli : $pembeli"),
              pf.Text("Menu ${menu}")
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
    var sum = 0;
    void jumlahSemua(int totalHarga, int totalBeli) {
      for (int i = 0; i < totalHarga; i++) {
        sum += totalHarga * totalBeli;
      }
      ;
    }

    return Scaffold(
        appBar: AppBar(
          title: Text("Nota"),
          centerTitle: true,
          backgroundColor: Colors.red[700],
          actions: [
            IconButton(
              onPressed: () async {
                // getDetailOrder(timeOrder);
                // GeneratePDF();
              },
              icon: Icon(Icons.print_outlined),
            )
          ],
        ),
        body: Container(
          margin: EdgeInsets.all(10),
          child: FutureBuilder(
            future: getDetailOrder(timeOrder),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: ClipPath(
                      clipper: FolderClipper(),
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        padding: EdgeInsets.only(top: 24),
                        color: Color(0XFFEAE7EA),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeader(
                              pengguna: "${snapshot.data![0].userName}",
                            ),
                            _buildAtasStruk(),
                            Column(
                              children: [
                                ClipPath(
                                  clipper: InvoiceContentClipper(),
                                  child: Container(
                                    color: Colors.white,
                                    padding: EdgeInsets.all(24),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Icon(Icons.file_copy),
                                            Text(
                                              "Detail Nota",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge!
                                                  .copyWith(
                                                      color: Colors.black),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "Email Pengguna",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .caption,
                                                  ),
                                                  SizedBox(height: 4),
                                                  Text("Jono@gmail.com"),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              width: .5,
                                              color: Colors.black38,
                                              height: 50,
                                            ),
                                            Expanded(
                                              child: Container(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      "Tanggal Struk",
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .caption,
                                                    ),
                                                    SizedBox(height: 4),
                                                    Text("23 oktober 2022"),
                                                  ],
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                        Container(
                                          width: double.infinity,
                                          height: .4,
                                          color: Colors.black,
                                          margin: EdgeInsets.symmetric(
                                              vertical: 20),
                                        ),
                                        Column(
                                          children: [
                                            ListView.builder(
                                              shrinkWrap: true,
                                              itemCount: snapshot.data!.length,
                                              itemBuilder: (context, index) {
                                                // jumlahSemua(
                                                //     snapshot
                                                //         .data![index].totalBeli,
                                                //     snapshot.data![index]
                                                //         .totalHarga);

                                                for (int i = 0;
                                                    i <
                                                        snapshot.data![index]
                                                            .totalBeli;
                                                    i++) {
                                                  sum += snapshot.data![index]
                                                          .totalBeli *
                                                      snapshot.data![index]
                                                          .totalHarga;
                                                }
                                                ;

                                                return Container(
                                                  margin: EdgeInsets.only(
                                                      bottom: 20),
                                                  child: Row(
                                                    children: [
                                                      // Ini adalah bentuk nota
                                                      Expanded(
                                                          child: Text(
                                                              "${snapshot.data![index].menu}\n ${snapshot.data![index].stand}")),
                                                      Container(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.1,
                                                        child: Text(
                                                            "${snapshot.data![index].totalBeli.toString()}x"),
                                                      ),
                                                      Expanded(
                                                        child: Text(
                                                            "Rp. ${snapshot.data![index].totalHarga.toString()}"),
                                                      ),
                                                      Expanded(
                                                        child: Text(
                                                            "Rp. ${snapshot.data![index].totalHarga * snapshot.data![index].totalBeli}"),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            ),
                                            Container(
                                              width: double.infinity,
                                              color: Colors.black38,
                                              height: .5,
                                              margin: EdgeInsets.symmetric(
                                                  vertical: 12),
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Expanded(child: Text("Total")),
                                                Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.1,
                                                  child: Text(""),
                                                ),
                                                Expanded(
                                                  child: Text(""),
                                                ),
                                                Expanded(
                                                  child: Text("Rp. ${sum}"),
                                                )
                                              ],
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
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
          ),
        ));
  }
}

class _buildContentInfo extends StatelessWidget {
  const _buildContentInfo(
      {Key? key, required this.emailPengguna, required this.tanggal})
      : super(key: key);

  final String emailPengguna;
  final String tanggal;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipPath(
          clipper: InvoiceContentClipper(),
          child: Container(
            color: Colors.white,
            padding: EdgeInsets.all(24),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.file_copy),
                    Text(
                      "Detail Nota",
                      style: Theme.of(context)
                          .textTheme
                          .headline6!
                          .copyWith(color: Colors.black),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Email Pengguna",
                            style: Theme.of(context).textTheme.caption,
                          ),
                          SizedBox(height: 4),
                          Text(emailPengguna),
                        ],
                      ),
                    ),
                    Container(
                      width: .5,
                      color: Colors.black38,
                      height: 50,
                    ),
                    Expanded(
                      child: Container(
                        alignment: Alignment.centerRight,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Tanggal Struk",
                              style: Theme.of(context).textTheme.caption,
                            ),
                            SizedBox(height: 4),
                            Text(tanggal),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
                Container(
                  width: double.infinity,
                  height: .4,
                  color: Colors.black,
                  margin: EdgeInsets.symmetric(vertical: 20),
                ),
                Column(
                  children: [
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: 2,
                      itemBuilder: (context, index) {
                        return Row(
                          children: [
                            // Ini adalah bentuk nota
                            Expanded(
                              child: Text("sf"),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.1,
                              child: Text("asdf"),
                            ),
                            Container(
                              child: Text("Rp"),
                            ),
                            Container(
                              child: Text("Rp"),
                            )
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _buildAtasStruk extends StatelessWidget {
  const _buildAtasStruk({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: InvoiceHeaderClipper(),
      child: Container(
        color: Colors.red[700],
        height: 100,
        padding: EdgeInsets.all(18),
        child: Row(
          children: [
            Icon(Icons.monetization_on, color: Colors.white),
            Text(
              " Struk Pembayaran",
              style: Theme.of(context)
                  .textTheme
                  .headline6!
                  .copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class _buildHeader extends StatelessWidget {
  const _buildHeader({Key? key, required this.pengguna}) : super(key: key);

  final String pengguna;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Struk Untuk",
            style: Theme.of(context).textTheme.bodyText2,
          ),
          Text(pengguna, style: Theme.of(context).textTheme.headline6
              // .copyWith(color: Colors.white),
              ),
        ],
      ),
    );
  }
}
