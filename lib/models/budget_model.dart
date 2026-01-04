import 'package:flutter/foundation.dart';

class BudgetModel {
  final String id;
  final String category;
  final double amount;
  final String month; // Format: YYYY-MM
  final DateTime createdAt;

  BudgetModel({
    required this.id,
    required this.category,
    required this.amount,
    required this.month,
    required this.createdAt,
  });

  // Factory untuk mengubah JSON (dari API) ke Object Dart
  factory BudgetModel.fromJson(Map<String, dynamic> json) {
    return BudgetModel(
      id: json['id'].toString(),
      category: json['category'],
      amount: double.parse(json['amount'].toString()),
      month: json['month'],
      createdAt: DateTime.parse(json['created_at'] ?? json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  // Method untuk mengubah Object Dart ke JSON (untuk dikirim ke API)
  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'amount': amount,
      'month': month,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

// Model untuk kategori transaksi
class CategoryModel {
  final String name;
  final String type; // 'INCOME' atau 'EXPENSE'

  CategoryModel({
    required this.name,
    required this.type,
  });

  // Daftar kategori standar
  static List<CategoryModel> get defaultCategories => [
        CategoryModel(name: 'Makanan', type: 'EXPENSE'),
        CategoryModel(name: 'Transportasi', type: 'EXPENSE'),
        CategoryModel(name: 'Hiburan', type: 'EXPENSE'),
        CategoryModel(name: 'Kesehatan', type: 'EXPENSE'),
        CategoryModel(name: 'Pendidikan', type: 'EXPENSE'),
        CategoryModel(name: 'Belanja', type: 'EXPENSE'),
        CategoryModel(name: 'Lainnya', type: 'EXPENSE'),
        CategoryModel(name: 'Gaji', type: 'INCOME'),
        CategoryModel(name: 'Bonus', type: 'INCOME'),
        CategoryModel(name: 'Investasi', type: 'INCOME'),
        CategoryModel(name: 'Lainnya', type: 'INCOME'),
      ];
}

// Provider untuk manajemen kategori
class CategoryProvider with ChangeNotifier {
  List<CategoryModel> _categories = [...CategoryModel.defaultCategories];

  List<CategoryModel> get categories => _categories;

  List<CategoryModel> get expenseCategories =>
      _categories.where((cat) => cat.type == 'EXPENSE').toList();

  List<CategoryModel> get incomeCategories =>
      _categories.where((cat) => cat.type == 'INCOME').toList();

  void addCategory(String name, String type) {
    // Cek apakah kategori sudah ada
    if (!_categories.any((cat) => cat.name == name && cat.type == type)) {
      _categories.add(CategoryModel(name: name, type: type));
      notifyListeners();
    }
  }

  void removeCategory(String name, String type) {
    _categories.removeWhere((cat) => cat.name == name && cat.type == type);
    notifyListeners();
  }
}