import 'dart:io';
import 'pdf_api.dart';
// import 'package:generate_pdf_invoice_example/model/customer.dart';
import '../model/invoice.dart';
// import 'package:generate_pdf_invoice_example/model/supplier.dart';
// import 'package:generate_pdf_invoice_example/utils.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/widgets.dart';

class PdfInvoiceApi {
  static Future<File> generate() async {
    final pdf = Document();

    pdf.addPage(MultiPage(
        build: (context) => [
              buildTitle(),
              buildInvoice(),
            ]));

    return PdfApi.saveDocument(name: "qanteen_${DateTime.now()}", pdf: pdf);
  }

  static Widget buildTitle() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'INVOICE',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 0.8 * PdfPageFormat.cm),
          Text("Deskripsi...."),
          SizedBox(height: 0.8 * PdfPageFormat.cm),
        ],
      );

  static Widget buildInvoice() {
    final headers = [
      'Menu',
      'Tanggal',
      'Jumlah',
      'Harga Item',
      'Nama Stand',
      'Total'
    ];
    return Center();
  }

}
