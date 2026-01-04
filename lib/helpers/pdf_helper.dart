import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../models/transaction_model.dart';

class PdfHelper {
  // Fungsi utama untuk generate dan print PDF
  static Future<void> generateAndPrint(List<TransactionModel> transactions) async {
    final pdf = pw.Document();

    // Buat format rupiah & tanggal khusus untuk PDF
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final dateFormatter = DateFormat('dd MMM yyyy');

    // Tambahkan halaman ke PDF
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // 1. Header Judul
              pw.Text("Laporan Keuangan Pribadi", style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Text("Dicetak pada: ${dateFormatter.format(DateTime.now())}"),
              pw.Divider(),
              pw.SizedBox(height: 20),

              // 2. Tabel Transaksi
              pw.Table.fromTextArray(
                headers: ['No', 'Tanggal', 'Keterangan', 'Tipe', 'Jumlah'],
                data: List<List<dynamic>>.generate(transactions.length, (index) {
                  final item = transactions[index];
                  return [
                    (index + 1).toString(), // Nomor urut
                    dateFormatter.format(item.date),
                    item.title,
                    item.type == 'EXPENSE' ? 'Pengeluaran' : 'Pemasukan',
                    currencyFormatter.format(item.amount),
                  ];
                }),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.blue),
                cellAlignment: pw.Alignment.centerLeft,
                cellAlignments: {
                   0: pw.Alignment.center, // Kolom No rata tengah
                   4: pw.Alignment.centerRight, // Kolom Jumlah rata kanan
                },
              ),
              
              // 3. Footer Total (Opsional)
              pw.SizedBox(height: 20),
              pw.Text("Akhir Laporan", style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey)),
            ],
          );
        },
      ),
    );

    // Membuka dialog print/share bawaan Android/iOS
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }
}