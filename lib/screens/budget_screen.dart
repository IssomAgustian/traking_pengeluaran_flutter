import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/budget_provider.dart';
import '../models/budget_model.dart';
import '../providers/transaction_provider.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  @override
  void initState() {
    super.initState();
    // Muat anggaran saat layar dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BudgetProvider>(context, listen: false).getAllBudgets();
    });
  }

  // Fungsi untuk menampilkan dialog pengaturan anggaran
  void _showBudgetDialog(BuildContext context, {BudgetModel? budget}) {
    final isEdit = budget != null;
    final monthController = TextEditingController(
      text: isEdit ? budget.month : DateFormat('yyyy-MM').format(DateTime.now()),
    );
    final categoryController = TextEditingController(
      text: isEdit ? budget.category : 'Makanan',
    );
    final amountController = TextEditingController(
      text: isEdit ? budget.amount.toString() : '',
    );

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(isEdit ? "Edit Anggaran" : "Tambah Anggaran"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: monthController,
                decoration: const InputDecoration(labelText: "Bulan (YYYY-MM)"),
                keyboardType: TextInputType.text,
              ),
              TextField(
                controller: categoryController,
                decoration: const InputDecoration(labelText: "Kategori"),
                keyboardType: TextInputType.text,
              ),
              TextField(
                controller: amountController,
                decoration: const InputDecoration(labelText: "Jumlah Anggaran"),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () {
                if (monthController.text.isEmpty || 
                    categoryController.text.isEmpty || 
                    amountController.text.isEmpty) return;

                final newBudget = BudgetModel(
                  id: isEdit ? budget.id : '',
                  category: categoryController.text,
                  amount: double.parse(amountController.text),
                  month: monthController.text,
                  createdAt: isEdit ? budget.createdAt : DateTime.now(),
                );

                if (isEdit) {
                  Provider.of<BudgetProvider>(context, listen: false)
                      .updateBudget(budget.id, newBudget);
                } else {
                  Provider.of<BudgetProvider>(context, listen: false)
                      .addBudget(newBudget);
                }
                Navigator.pop(context);
              },
              child: const Text("Simpan"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Anggaran Bulanan"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showBudgetDialog(context),
          ),
        ],
      ),
      body: Consumer2<BudgetProvider, TransactionProvider>(
        builder: (context, budgetProvider, transactionProvider, child) {
          if (budgetProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
            itemCount: budgetProvider.budgets.length,
            itemBuilder: (context, index) {
              final budget = budgetProvider.budgets[index];
              final currentSpending = transactionProvider.getTotalExpenseByCategory(budget.category);
              final isExceeded = currentSpending > budget.amount && budget.amount > 0;
              final percentage = budget.amount > 0 ? (currentSpending / budget.amount) * 100 : 0;

              return Card(
                margin: const EdgeInsets.all(8),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              "${budget.category} - ${budget.month}",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _showBudgetDialog(context, budget: budget),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Anggaran: ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(budget.amount)}",
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Terpakai: ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(currentSpending)}",
                        style: TextStyle(
                          fontSize: 16,
                          color: isExceeded ? Colors.red : Colors.green,
                        ),
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: percentage > 100 ? 1 : percentage / 100,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isExceeded ? Colors.red : Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${percentage.toStringAsFixed(1)}%",
                        style: TextStyle(
                          color: isExceeded ? Colors.red : Colors.black54,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (isExceeded)
                        const Text(
                          "Melebihi anggaran!",
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}