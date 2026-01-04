import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/transaction_model.dart';

class ApiService {
  // PENTING: Ketik ulang baris ini manual jangan copy-paste untuk menghindari error spasi/karakter aneh
  final String baseUrl = "http://10.173.166.186:8000"; // Server berjalan di direktori backend
  // For testing with local server, use: http://10.173.166.186:8000

  // 1. GET (Read)
  Future<List<TransactionModel>> getTransactions() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/read.php"),
        headers: {"content-type": "application/json"},
      );

      print('API Response Status: ${response.statusCode}');
      print('API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((item) => TransactionModel.fromJson(item)).toList();
      } else {
        throw Exception('Gagal ambil data: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error fetching transactions: $e');
      throw Exception('Gagal ambil data: $e');
    }
  }

  // 2. POST (Create)
  Future<bool> createTransaction(TransactionModel data) async {
    final response = await http.post(
      Uri.parse("$baseUrl/create.php"),
      headers: {"content-type": "application/json"},
      body: jsonEncode(data.toJson()),
    );
    return response.statusCode == 200;
  }

  // 3. DELETE (Hapus) - INI YANG KEMARIN HILANG/ERROR
  Future<bool> deleteTransaction(String id) async {
    final response = await http.post(
      Uri.parse("$baseUrl/delete.php"),
      headers: {"content-type": "application/json"},
      body: jsonEncode({"id": id}),
    );
    return response.statusCode == 200;
  }

  // 4. UPDATE (Edit Data) - Persiapan untuk nanti
  Future<bool> updateTransaction(String id, TransactionModel data) async {
    final response = await http.post(
      Uri.parse("$baseUrl/update.php"),
      headers: {"content-type": "application/json"},
      // Kita gabungkan ID dengan data yang mau diedit
      body: jsonEncode({...data.toJson(), "id": id}),
    );

    return response.statusCode == 200;
  }
}
