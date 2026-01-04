import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/budget_model.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manajemen Kategori"),
      ),
      body: Consumer<CategoryProvider>(
        builder: (context, categoryProvider, child) {
          return Column(
            children: [
              // Tambahkan kategori baru
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Text(
                          "Tambah Kategori Baru",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                decoration: const InputDecoration(
                                  labelText: "Nama Kategori",
                                  border: OutlineInputBorder(),
                                ),
                                onSubmitted: (value) {
                                  _showAddCategoryDialog(context, categoryProvider);
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: () => _showAddCategoryDialog(context, categoryProvider),
                              child: const Text("Tambah"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Daftar kategori
              Expanded(
                child: ListView(
                  children: [
                    _buildCategorySection("Pengeluaran", "EXPENSE", categoryProvider),
                    _buildCategorySection("Pemasukan", "INCOME", categoryProvider),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCategorySection(String title, String type, CategoryProvider provider) {
    final categories = type == 'EXPENSE' 
        ? provider.expenseCategories 
        : provider.incomeCategories;

    return Card(
      margin: const EdgeInsets.all(16),
      child: ExpansionTile(
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        children: [
          if (categories.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text("Belum ada kategori"),
            )
          else
            ...categories.map((category) => ListTile(
                  title: Text(category.name),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      provider.removeCategory(category.name, category.type);
                    },
                  ),
                )).toList(),
        ],
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context, CategoryProvider provider) {
    String categoryName = "";
    String categoryType = "EXPENSE";

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("Tambah Kategori"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: "Nama Kategori"),
                onChanged: (value) => categoryName = value,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: categoryType,
                decoration: const InputDecoration(labelText: "Tipe Kategori"),
                items: const [
                  DropdownMenuItem(value: "EXPENSE", child: Text("Pengeluaran")),
                  DropdownMenuItem(value: "INCOME", child: Text("Pemasukan")),
                ],
                onChanged: (value) {
                  if (value != null) {
                    categoryType = value;
                  }
                },
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
                if (categoryName.isNotEmpty) {
                  provider.addCategory(categoryName, categoryType);
                  Navigator.pop(context);
                }
              },
              child: const Text("Tambah"),
            ),
          ],
        );
      },
    );
  }
}