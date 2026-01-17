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
    final amountController = TextEditingController(
      text: isEdit ? budget.amount.toString() : '',
    );
    String selectedCategory = isEdit ? budget.category : '';

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setStateDialog) {
            Future<void> pickMonth() async {
              final parsed = DateTime.tryParse('${monthController.text}-01');
              final initialDate = parsed ?? DateTime.now();
              final picked = await showDatePicker(
                context: ctx,
                initialDate: initialDate,
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
                helpText: 'Pilih Bulan',
              );
              if (picked != null) {
                setStateDialog(() {
                  monthController.text =
                      DateFormat('yyyy-MM').format(DateTime(picked.year, picked.month));
                });
              }
            }

            return AlertDialog(
              title: Text(isEdit ? "Edit Anggaran" : "Tambah Anggaran"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: monthController,
                    decoration: const InputDecoration(
                      labelText: "Bulan (YYYY-MM)",
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    readOnly: true,
                    onTap: pickMonth,
                  ),
                  const SizedBox(height: 12),
                  Consumer<CategoryProvider>(
                    builder: (context, categoryProvider, child) {
                      final categories = categoryProvider.expenseCategories;
                      if (selectedCategory.isEmpty && categories.isNotEmpty) {
                        selectedCategory = categories.first.name;
                      } else if (selectedCategory.isNotEmpty &&
                          categories.isNotEmpty &&
                          !categories.any((cat) => cat.name == selectedCategory)) {
                        selectedCategory = categories.first.name;
                      }

                      return DropdownButtonFormField<String>(
                        value: selectedCategory.isNotEmpty ? selectedCategory : null,
                        decoration: const InputDecoration(
                          labelText: "Kategori",
                          border: OutlineInputBorder(),
                        ),
                        items: categories
                            .map((cat) => DropdownMenuItem(
                                  value: cat.name,
                                  child: Text(cat.name),
                                ))
                            .toList(),
                        onChanged: categories.isEmpty
                            ? null
                            : (value) {
                                if (value != null) {
                                  setStateDialog(() {
                                    selectedCategory = value;
                                  });
                                }
                              },
                      );
                    },
                  ),
                  const SizedBox(height: 12),
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
                        selectedCategory.isEmpty ||
                        amountController.text.isEmpty) {
                      return;
                    }

                    final newBudget = BudgetModel(
                      id: isEdit ? budget.id : '',
                      category: selectedCategory,
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
      },
    );
  }

  void _confirmDeleteBudget(BuildContext context, BudgetModel budget) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("Hapus Anggaran"),
          content: Text("Hapus anggaran ${budget.category} - ${budget.month}?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () {
                Provider.of<BudgetProvider>(context, listen: false)
                    .deleteBudget(budget.id);
                Navigator.pop(context);
              },
              child: const Text("Hapus"),
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
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _showBudgetDialog(context, budget: budget),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _confirmDeleteBudget(context, budget),
                              ),
                            ],
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
