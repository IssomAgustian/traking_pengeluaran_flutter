import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../providers/theme_provider.dart'; // Import theme provider
import '../models/transaction_model.dart';
import '../helpers/pdf_helper.dart';
import '../screens/budget_screen.dart'; // Import layar anggaran
import '../screens/chart_screen.dart'; // Import layar grafik
import '../screens/category_screen.dart'; // Import layar manajemen kategori
import '../models/budget_model.dart'; // Import model kategori

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchQuery = ''; // Tambahkan variabel untuk pencarian
  String _selectedType = 'ALL'; // Tambahkan variabel untuk filter tipe
  DateTime? _selectedDateRangeStart; // Tambahkan variabel untuk filter tanggal
  DateTime? _selectedDateRangeEnd;

  // Panggil data saat aplikasi pertama kali dibuka
  @override
  void initState() {
    super.initState();
    // Microtask agar tidak error saat build belum selesai
    Future.microtask(() =>
        Provider.of<TransactionProvider>(context, listen: false)
            .getAllTransactions());
  }

  // Fungsi helper format rupiah
  String formatRupiah(double amount) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(amount);
  }

  // Fungsi Menampilkan Dialog Tambah Data
  void _showFormDialog(BuildContext context, {TransactionModel? transaction}) {
    // Jika 'transaction' ada isinya, berarti mode EDIT. Jika null, mode TAMBAH.
    final isEdit = transaction != null;

    final titleController = TextEditingController(text: isEdit ? transaction.title : '');
    final amountController = TextEditingController(text: isEdit ? transaction.amount.toString() : '');
    String type = isEdit ? transaction.type : 'EXPENSE';
    String category = isEdit ? transaction.category : 'Makanan'; // Default kategori

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(isEdit ? "Edit Transaksi" : "Tambah Transaksi"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleController, decoration: const InputDecoration(labelText: "Judul")),
              TextField(controller: amountController, decoration: const InputDecoration(labelText: "Nominal"), keyboardType: TextInputType.number),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: type,
                items: const [
                  DropdownMenuItem(value: "EXPENSE", child: Text("Pengeluaran")),
                  DropdownMenuItem(value: "INCOME", child: Text("Pemasukan")),
                ],
                onChanged: (value) => type = value!,
              ),
              const SizedBox(height: 10),
              Consumer<CategoryProvider>(
                builder: (context, categoryProvider, child) {
                  final categories = type == 'EXPENSE'
                      ? categoryProvider.expenseCategories
                      : categoryProvider.incomeCategories;
                  return DropdownButtonFormField<String>(
                    value: category,
                    items: categories
                        .map((cat) => DropdownMenuItem(
                              value: cat.name,
                              child: Text(cat.name),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        category = value;
                        // If the selected category doesn't exist in the provider, add it
                        if (!categories.any((cat) => cat.name == value)) {
                          categoryProvider.addCategory(value, type);
                        }
                      }
                    },
                  );
                },
              )
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isEmpty || amountController.text.isEmpty) return;

                final data = TransactionModel(
                  id: isEdit ? transaction.id : '', // ID lama jika edit
                  title: titleController.text,
                  amount: double.parse(amountController.text),
                  type: type,
                  category: category, // Tambahkan kategori
                  date: isEdit ? transaction.date : DateTime.now(), // Tanggal lama jika edit
                );

                if (isEdit) {
                  // Panggil fungsi UPDATE
                  Provider.of<TransactionProvider>(context, listen: false)
                      .updateTransaction(transaction.id, data);
                } else {
                  // Panggil fungsi CREATE
                  Provider.of<TransactionProvider>(context, listen: false)
                      .addTransaction(data);
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

  // Fungsi untuk menampilkan dialog filter
  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("Filter Transaksi"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(labelText: "Tipe Transaksi"),
                items: const [
                  DropdownMenuItem(value: 'ALL', child: Text("Semua")),
                  DropdownMenuItem(value: 'INCOME', child: Text("Pemasukan")),
                  DropdownMenuItem(value: 'EXPENSE', child: Text("Pengeluaran")),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedType = value!;
                  });
                },
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () async {
                  final DateTime? pickedStart = await showDatePicker(
                    context: context,
                    initialDate: _selectedDateRangeStart ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (pickedStart != null) {
                    setState(() {
                      _selectedDateRangeStart = pickedStart;
                    });
                  }
                },
                child: Text(_selectedDateRangeStart != null
                    ? 'Tanggal Mulai: ${DateFormat('dd/MM/yyyy').format(_selectedDateRangeStart!)}'
                    : 'Pilih Tanggal Mulai'),
              ),
              TextButton(
                onPressed: () async {
                  final DateTime? pickedEnd = await showDatePicker(
                    context: context,
                    initialDate: _selectedDateRangeEnd ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (pickedEnd != null) {
                    setState(() {
                      _selectedDateRangeEnd = pickedEnd;
                    });
                  }
                },
                child: Text(_selectedDateRangeEnd != null
                    ? 'Tanggal Akhir: ${DateFormat('dd/MM/yyyy').format(_selectedDateRangeEnd!)}'
                    : 'Pilih Tanggal Akhir'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Reset filter
                setState(() {
                  _selectedType = 'ALL';
                  _selectedDateRangeStart = null;
                  _selectedDateRangeEnd = null;
                });
                Navigator.pop(context);
              },
              child: const Text("Reset"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Tutup"),
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
        title: const Text("Expense Tracker"),
        actions: [
          // Tombol untuk membuka layar anggaran
          IconButton(
            icon: const Icon(Icons.account_balance_wallet),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BudgetScreen()),
              );
            },
          ),
          // Tombol untuk membuka layar manajemen kategori
          IconButton(
            icon: const Icon(Icons.category),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CategoryScreen()),
              );
            },
          ),
          // Tombol untuk membuka layar grafik
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChartScreen()),
              );
            },
          ),
          // Tombol filter
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
          ),
          // Tombol toggle tema gelap
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return IconButton(
                icon: Icon(
                  themeProvider.isDarkMode
                    ? Icons.light_mode
                    : Icons.dark_mode,
                ),
                onPressed: () {
                  themeProvider.toggleTheme();
                },
              );
            },
          ),
          // Tombol Print PDF
          Consumer<TransactionProvider>(
            builder: (context, provider, child) {
              return IconButton(
                icon: const Icon(Icons.print),
                onPressed: () {
                  if (provider.transactions.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Tidak ada data untuk dicetak")),
                    );
                  } else {
                    // Panggil fungsi Helper
                    PdfHelper.generateAndPrint(provider.transactions);
                  }
                },
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Kotak pencarian
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: "Cari transaksi...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          // --- KOTAK DASHBOARD SALDO ---
          Card(
            margin: const EdgeInsets.all(16),
            color: Colors.blueAccent,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text("Sisa Saldo", style: TextStyle(color: Colors.white)),
                  Consumer<TransactionProvider>(
                    builder: (context, provider, child) {
                      return Text(formatRupiah(provider.totalBalance),
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white));
                    },
                  ),
                  const SizedBox(height: 10),
                  Consumer<TransactionProvider>(
                    builder: (context, provider, child) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Masuk: ${formatRupiah(provider.totalIncome)}", style: const TextStyle(color: Colors.white70)),
                          Text("Keluar: ${formatRupiah(provider.totalExpense)}", style: const TextStyle(color: Colors.white70)),
                        ],
                      );
                    },
                  )
                ],
              ),
            ),
          ),
          // --- LIST TRANSAKSI ---
          Expanded(
            child: Consumer<TransactionProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Dapatkan daftar transaksi yang sudah difilter dan dicari
                var filteredTransactions = provider.transactions;

                // Terapkan pencarian
                if (_searchQuery.isNotEmpty) {
                  filteredTransactions = provider.searchTransactions(_searchQuery);
                }

                // Terapkan filter tipe
                if (_selectedType != 'ALL') {
                  filteredTransactions = provider.filterByType(_selectedType);
                }

                // Terapkan filter tanggal jika ada
                if (_selectedDateRangeStart != null && _selectedDateRangeEnd != null) {
                  filteredTransactions = provider.filterByDate(_selectedDateRangeStart!, _selectedDateRangeEnd!);
                }

                return filteredTransactions.isEmpty
                    ? const Center(child: Text("Belum ada data"))
                    : ListView.builder(
                        itemCount: filteredTransactions.length,
                        itemBuilder: (context, index) {
                          final item = filteredTransactions[index];
                          final isExpense = item.type == 'EXPENSE';

                          return Dismissible(
                            key: Key(item.id),
                            // ... kode background dismissible tetap sama ...
                            onDismissed: (direction) {
                              provider.deleteTransaction(item.id);
                            },
                            child: ListTile(
                              // --- UPDATE LOGIC: Klik item untuk EDIT ---
                              onTap: () => _showFormDialog(context, transaction: item),

                              leading: CircleAvatar(
                                backgroundColor: isExpense ? Colors.red[100] : Colors.green[100],
                                child: Icon(isExpense ? Icons.arrow_downward : Icons.arrow_upward,
                                    color: isExpense ? Colors.red : Colors.green),
                              ),
                              title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text("${item.category} • ${DateFormat('dd MMM yyyy').format(item.date)}"),
                              trailing: Text(formatRupiah(item.amount),
                                  style: TextStyle(color: isExpense ? Colors.red : Colors.green, fontWeight: FontWeight.bold)),
                            ),
                          );
                        },
                      );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        // Panggil dialog tanpa parameter untuk mode TAMBAH
        onPressed: () => _showFormDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}