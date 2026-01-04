import 'package:flutter/material.dart';
import '../models/budget_model.dart';
import '../models/transaction_model.dart'; // Tambahkan import TransactionModel
import '../services/budget_api_service.dart';

class BudgetProvider with ChangeNotifier {
  final BudgetApiService _apiService = BudgetApiService();

  List<BudgetModel> _budgets = [];
  bool _isLoading = false;

  // Getter
  List<BudgetModel> get budgets => _budgets;
  bool get isLoading => _isLoading;

  // Fetch semua anggaran
  Future<void> getAllBudgets() async {
    _isLoading = true;
    notifyListeners();

    try {
      _budgets = await _apiService.getBudgets();
    } catch (e) {
      print("Error fetching budgets: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  // Fetch anggaran berdasarkan bulan
  Future<void> getBudgetsByMonth(String month) async {
    _isLoading = true;
    notifyListeners();

    try {
      _budgets = await _apiService.getBudgetsByMonth(month);
    } catch (e) {
      print("Error fetching budgets for month $month: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  // Tambah anggaran
  Future<void> addBudget(BudgetModel budget) async {
    await _apiService.createBudget(budget);
    await getAllBudgets(); // Refresh data
  }

  // Update anggaran
  Future<void> updateBudget(String id, BudgetModel budget) async {
    await _apiService.updateBudget(id, budget);
    await getAllBudgets(); // Refresh data
  }

  // Hapus anggaran
  Future<void> deleteBudget(String id) async {
    await _apiService.deleteBudget(id);
    await getAllBudgets(); // Refresh data
  }

  // Cek apakah anggaran untuk kategori tertentu sudah terlampaui
  bool isBudgetExceeded(String category, String month, double currentSpending) {
    final budget = _budgets.firstWhere(
      (b) => b.category == category && b.month == month,
      orElse: () => BudgetModel(
        id: '',
        category: category,
        amount: 0,
        month: month,
        createdAt: DateTime.now(),
      ),
    );
    return currentSpending > budget.amount && budget.amount > 0;
  }

  // Dapatkan anggaran untuk kategori tertentu
  BudgetModel? getBudgetForCategory(String category, String month) {
    try {
      return _budgets.firstWhere(
        (b) => b.category == category && b.month == month,
      );
    } catch (e) {
      return null;
    }
  }

  // Dapatkan total pengeluaran untuk kategori tertentu dalam bulan tertentu
  double getTotalSpendingForCategory(String category, String month, List<TransactionModel> transactions) {
    final monthStart = DateTime.parse('$month-01');
    final monthEnd = DateTime(monthStart.year, monthStart.month + 1, 0); // Akhir bulan

    return transactions
        .where((t) => 
          t.type == 'EXPENSE' && 
          t.category == category && 
          t.date.isAfter(monthStart) && 
          t.date.isBefore(monthEnd.add(Duration(days: 1)))
        )
        .fold(0.0, (sum, item) => sum + item.amount);
  }
}