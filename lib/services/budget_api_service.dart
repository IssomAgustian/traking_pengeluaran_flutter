import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/budget_model.dart';
import 'api_config.dart';

class BudgetApiService {
  final String baseUrl = ApiConfig.baseUrl;

  // GET semua anggaran
  Future<List<BudgetModel>> getBudgets() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/budgets/read.php"),
        headers: {"content-type": "application/json"},
      );

      print('Budget API Response Status: ${response.statusCode}');
      print('Budget API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((item) => BudgetModel.fromJson(item)).toList();
      } else {
        throw Exception('Gagal ambil data anggaran: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error fetching budgets: $e');
      throw Exception('Gagal ambil data anggaran: $e');
    }
  }

  // GET anggaran berdasarkan bulan dan tahun
  Future<List<BudgetModel>> getBudgetsByMonth(String month) async {
    final response = await http.get(Uri.parse("$baseUrl/budgets/read_by_month.php?month=$month"));
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((item) => BudgetModel.fromJson(item)).toList();
    } else {
      throw Exception('Gagal ambil data anggaran untuk bulan $month');
    }
  }

  // CREATE anggaran baru
  Future<bool> createBudget(BudgetModel budget) async {
    final response = await http.post(
      Uri.parse("$baseUrl/budgets/create.php"),
      headers: {"content-type": "application/json"},
      body: jsonEncode(budget.toJson()),
    );
    return response.statusCode == 200;
  }

  // UPDATE anggaran
  Future<bool> updateBudget(String id, BudgetModel budget) async {
    final response = await http.post(
      Uri.parse("$baseUrl/budgets/update.php"),
      headers: {"content-type": "application/json"},
      body: jsonEncode({...budget.toJson(), "id": id}),
    );
    return response.statusCode == 200;
  }

  // DELETE anggaran
  Future<bool> deleteBudget(String id) async {
    final response = await http.post(
      Uri.parse("$baseUrl/budgets/delete.php"),
      headers: {"content-type": "application/json"},
      body: jsonEncode({"id": id}),
    );
    return response.statusCode == 200;
  }
}
