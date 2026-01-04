class TransactionModel {
  final String id;
  final String title;
  final double amount;
  final String type;
  final String category; // Menambahkan kategori
  final DateTime date;

  TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.category, // Menambahkan parameter kategori
    required this.date,
  });

  // Factory untuk mengubah JSON (dari API) ke Object Dart
  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'].toString(),
      title: json['title'],
      amount: double.parse(json['amount'].toString()),
      type: json['type'],
      category: json['category'] ?? 'Lainnya', // Default ke 'Lainnya' jika tidak ada
      date: DateTime.parse(json['date']),
    );
  }

  // Method untuk mengubah Object Dart ke JSON (untuk dikirim ke API)
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'amount': amount,
      'type': type,
      'category': category, // Menambahkan kategori ke JSON
      'date': date.toIso8601String(),
    };
  }
}