import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import './providers/transaction_provider.dart';
import './providers/budget_provider.dart'; // Tambahkan import budget provider
import './providers/theme_provider.dart'; // Tambahkan import theme provider
import './models/budget_model.dart'; // Import CategoryProvider
import './screens/home_screen.dart';

void main() async {
  // Initialize date formatting for Indonesian locale
  await initializeDateFormatting('id_ID', null);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => BudgetProvider()), // Tambahkan budget provider
        ChangeNotifierProvider(create: (_) => ThemeProvider()), // Tambahkan theme provider
        ChangeNotifierProvider(create: (_) => CategoryProvider()), // Tambahkan category provider
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Expense Tracker',
          theme: ThemeData(  // Tema terang
            primarySwatch: Colors.blue,
            brightness: Brightness.light,
          ),
          darkTheme: ThemeData(  // Tema gelap
            primarySwatch: Colors.blue,
            brightness: Brightness.dark,
          ),
          themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: const HomeScreen(),
        );
      },
    );
  }
}