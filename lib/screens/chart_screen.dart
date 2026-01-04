import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';

class ChartScreen extends StatefulWidget {
  const ChartScreen({super.key});

  @override
  State<ChartScreen> createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen> {
  String _selectedPeriod = 'month'; // 'month', 'year'

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Laporan Grafik"),
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Filter transaksi berdasarkan periode
          List<DateTime> availableMonths = [];
          for (var transaction in provider.transactions) {
            String monthKey = "${transaction.date.year}-${transaction.date.month.toString().padLeft(2, '0')}";
            if (!availableMonths.any((dt) =>
                "${dt.year}-${dt.month.toString().padLeft(2, '0')}" == monthKey)) {
              availableMonths.add(DateTime(transaction.date.year, transaction.date.month));
            }
          }

          // Urutkan bulan dari terbaru ke terlama
          availableMonths.sort((a, b) => b.compareTo(a));

          return Column(
            children: [
              // Pilihan periode
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Text("Periode: "),
                    DropdownButton<String>(
                      value: _selectedPeriod,
                      items: const [
                        DropdownMenuItem(value: 'month', child: Text("Bulanan")),
                        DropdownMenuItem(value: 'year', child: Text("Tahunan")),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedPeriod = value!;
                        });
                      },
                    ),
                    const Spacer(),
                    if (_selectedPeriod == 'month' && availableMonths.isNotEmpty)
                      DropdownButton<DateTime>(
                        value: availableMonths.isNotEmpty ? availableMonths.first : null,
                        items: availableMonths.map((month) {
                          return DropdownMenuItem(
                            value: month,
                            child: Text(DateFormat('MMMM yyyy', 'id_ID').format(month)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          // Untuk sementara, kita hanya menampilkan grafik untuk bulan yang dipilih
                        },
                      ),
                  ],
                ),
              ),

              // Grafik Pie untuk pengeluaran berdasarkan kategori
              Expanded(
                child: _buildExpenseChart(provider),
              ),

              // Grafik Bar untuk pemasukan vs pengeluaran
              Container(
                height: 200,
                padding: const EdgeInsets.all(16),
                child: _buildIncomeExpenseChart(provider),
              ),
            ],
          );
        },
      ),
    );
  }

  // Grafik Pie untuk pengeluaran berdasarkan kategori
  Widget _buildExpenseChart(TransactionProvider provider) {
    // Ambil pengeluaran berdasarkan kategori
    Map<String, double> categoryExpenses = {};

    for (var transaction in provider.transactions) {
      if (transaction.type == 'EXPENSE') {
        categoryExpenses[transaction.category] =
          (categoryExpenses[transaction.category] ?? 0) + transaction.amount;
      }
    }

    if (categoryExpenses.isEmpty) {
      return const Center(
        child: Text("Tidak ada data pengeluaran untuk ditampilkan"),
      );
    }

    List<PieChartSectionData> sections = [];
    List<Color> colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.brown,
      Colors.pink,
      Colors.teal,
      Colors.cyan,
      Colors.amber,
    ];

    int colorIndex = 0;
    double total = categoryExpenses.values.fold(0.0, (a, b) => a + b);

    categoryExpenses.forEach((category, amount) {
      final percentage = (amount / total) * 100;
      sections.add(
        PieChartSectionData(
          color: colors[colorIndex % colors.length],
          value: amount,
          title: '${percentage.toStringAsFixed(1)}%',
          radius: 50,
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
      colorIndex++;
    });

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              "Distribusi Pengeluaran Berdasarkan Kategori",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: PieChart(
                PieChartData(
                  sections: sections,
                  centerSpaceRadius: 40,
                  sectionsSpace: 2,
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {},
                  ),
                  borderData: FlBorderData(
                    show: false,
                  ),
                ),
              ),
            ),
            // Legenda
            Wrap(
              spacing: 8,
              children: categoryExpenses.entries.map((entry) {
                int index = categoryExpenses.keys.toList().indexOf(entry.key);
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: colors[index % colors.length],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "${entry.key}: ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(entry.value)}",
                      style: const TextStyle(fontSize: 10),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  // Grafik Bar untuk pemasukan vs pengeluaran
  Widget _buildIncomeExpenseChart(TransactionProvider provider) {
    // Ambil data bulanan
    Map<String, Map<String, double>> monthlyData = {};

    for (var transaction in provider.transactions) {
      String monthKey = "${transaction.date.year}-${transaction.date.month.toString().padLeft(2, '0')}";

      if (!monthlyData.containsKey(monthKey)) {
        monthlyData[monthKey] = {'income': 0, 'expense': 0};
      }

      if (transaction.type == 'INCOME') {
        monthlyData[monthKey]!['income'] =
          (monthlyData[monthKey]!['income'] ?? 0) + transaction.amount;
      } else if (transaction.type == 'EXPENSE') {
        monthlyData[monthKey]!['expense'] =
          (monthlyData[monthKey]!['expense'] ?? 0) + transaction.amount;
      }
    }

    // Ambil 6 bulan terakhir
    var sortedMonths = monthlyData.keys.toList();
    sortedMonths.sort();
    if (sortedMonths.length > 6) {
      sortedMonths = sortedMonths.sublist(sortedMonths.length - 6);
    }

    List<BarChartGroupData> barGroups = [];
    List<String> xAxisLabels = [];

    for (int i = 0; i < sortedMonths.length; i++) {
      String month = sortedMonths[i];
      double income = monthlyData[month]!['income'] ?? 0;
      double expense = monthlyData[month]!['expense'] ?? 0;

      xAxisLabels.add(DateFormat('MMM', 'id_ID').format(DateTime.parse('$month-01')));

      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: income,
              color: Colors.green,
              width: 15,
            ),
            BarChartRodData(
              toY: expense,
              color: Colors.red,
              width: 15,
              borderSide: const BorderSide(width: 1, color: Colors.white),
            ),
          ],
        ),
      );
    }

    if (barGroups.isEmpty) {
      return Container(
        alignment: Alignment.center,
        child: const Text("Tidak ada data untuk ditampilkan"),
      );
    }

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              "Pemasukan vs Pengeluaran (6 Bulan Terakhir)",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: BarChart(
                BarChartData(
                  barGroups: barGroups,
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        String month = xAxisLabels[group.x];
                        String type = rodIndex == 0 ? 'Pemasukan' : 'Pengeluaran';
                        double value = rod.toY;
                        return BarTooltipItem(
                          '$month\n$type: ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(value)}',
                          const TextStyle(color: Colors.white),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          int index = value.toInt();
                          if (index >= 0 && index < xAxisLabels.length) {
                            return SideTitleWidget(
                              axisSide: meta.axisSide,
                              space: 4,
                              child: Text(xAxisLabels[index]),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                      ),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.grey.withOpacity(0.2)),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    drawHorizontalLine: true,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey,
                        strokeWidth: 0.5,
                      );
                    },
                    getDrawingVerticalLine: (value) {
                      return FlLine(
                        color: Colors.grey,
                        strokeWidth: 0.5,
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}