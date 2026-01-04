import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../services/api_service.dart';

class TransactionProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<TransactionModel> _transactions = [];
  bool _isLoading = false;

  // Getter agar data bisa dibaca oleh UI
  List<TransactionModel> get transactions => _transactions;
  bool get isLoading => _isLoading;

  // 1. Fetch Data (Read)
  Future<void> getAllTransactions() async {
    _isLoading = true;
    notifyListeners();

    try {
      _transactions = await _apiService.getTransactions();
      // Sortir agar yang terbaru muncul di atas
      _transactions.sort((a, b) => b.date.compareTo(a.date));
    } catch (e) {
      print("Error fetching data: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  // 2. Add Data (Create)
  Future<void> addTransaction(TransactionModel transaction) async {
    await _apiService.createTransaction(transaction);
    await getAllTransactions(); // Refresh list setelah nambah data
  }

  // 3. Delete Data (Delete)
  Future<void> deleteTransaction(String id) async {
    await _apiService.deleteTransaction(id);
    await getAllTransactions(); // Refresh list setelah hapus
  }
  // --- TAMBAHAN 1: GETTER UNTUK DASHBOARD ---
  // Hitung Pemasukan
  double get totalIncome {
    return _transactions
        .where((item) => item.type == 'INCOME')
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  // Hitung Pengeluaran
  double get totalExpense {
    return _transactions
        .where((item) => item.type == 'EXPENSE')
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  // Hitung Sisa Saldo
  double get totalBalance => totalIncome - totalExpense;


  // --- TAMBAHAN 2: FUNGSI UPDATE ---
  Future<void> updateTransaction(String id, TransactionModel transaction) async {
    // Panggil API Update
    await _apiService.updateTransaction(id, transaction);
    // Refresh list agar perubahan langsung muncul
    await getAllTransactions();
  }

  // --- TAMBAHAN 3: FUNGSI UNTUK KATEGORI ---
  // Dapatkan daftar kategori unik
  List<String> get uniqueCategories {
    final categories = <String>{};
    for (final transaction in _transactions) {
      categories.add(transaction.category);
    }
    return categories.toList();
  }

  // Dapatkan total pengeluaran berdasarkan kategori
  double getTotalExpenseByCategory(String category) {
    return _transactions
        .where((item) => item.type == 'EXPENSE' && item.category == category)
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  // Dapatkan total pemasukan berdasarkan kategori
  double getTotalIncomeByCategory(String category) {
    return _transactions
        .where((item) => item.type == 'INCOME' && item.category == category)
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  // Dapatkan transaksi berdasarkan kategori
  List<TransactionModel> getTransactionsByCategory(String category) {
    return _transactions.where((item) => item.category == category).toList();
  }

  // --- TAMBAHAN 4: FUNGSI PENCARIAN DAN FILTER ---
  // Pencarian transaksi
  List<TransactionModel> searchTransactions(String query) {
    if (query.isEmpty) return _transactions;
    return _transactions.where((item) {
      final lowerQuery = query.toLowerCase();
      return item.title.toLowerCase().contains(lowerQuery) ||
             item.amount.toString().contains(lowerQuery) ||
             item.category.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  // Filter transaksi berdasarkan tanggal
  List<TransactionModel> filterByDate(DateTime startDate, DateTime endDate) {
    return _transactions.where((item) {
      return item.date.isAfter(startDate.subtract(Duration(days: 1))) &&
             item.date.isBefore(endDate.add(Duration(days: 1)));
    }).toList();
  }

  // Filter transaksi berdasarkan tipe
  List<TransactionModel> filterByType(String type) {
    return _transactions.where((item) => item.type == type).toList();
  }

  // Filter transaksi berdasarkan bulan
  List<TransactionModel> filterByMonth(int month, int year) {
    return _transactions.where((item) {
      return item.date.month == month && item.date.year == year;
    }).toList();
  }
}
