import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:apartment_manager/provider/report_provider.dart';
//import 'package:apartment_manager/model/report_model.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ReportProvider>(context, listen: false).loadReports();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ReportProvider>(
      builder: (context, reportProvider, _) {
        return Scaffold(
          appBar: AppBar(title: const Text("Report")),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: reportProvider.reports.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Month Filter
                        DropdownButton<String>(
                          value: reportProvider.selectedMonth,
                          onChanged: (value) {
                            if (value != null) {
                              reportProvider.changeMonth(value);
                            }
                          },
                          items: List.generate(12, (index) {
                            final month = DateFormat('MMMM yyyy').format(
                                DateTime(DateTime.now().year, index + 1));
                            return DropdownMenuItem(
                              value: month,
                              child: Text(month),
                            );
                          }),
                        ),
                        const SizedBox(height: 20),

                        // Summary
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _summaryCard("Credit", reportProvider.totalCredit,
                                Colors.green),
                            _summaryCard(
                                "Debit", reportProvider.totalDebit, Colors.red),
                            _summaryCard(
                                "Balance",
                                reportProvider.balance,
                                reportProvider.balance >= 0
                                    ? Colors.blue
                                    : Colors.red),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Pie Chart
                        const Text("Category-wise Debit Breakdown"),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 200,
                          child: PieChart(
                            PieChartData(
                              sections: reportProvider.categoryWiseDebit.entries
                                  .map((entry) {
                                final color = Colors.primaries[reportProvider
                                        .categoryWiseDebit.keys
                                        .toList()
                                        .indexOf(entry.key) %
                                    Colors.primaries.length];
                                return PieChartSectionData(
                                  value: entry.value,
                                  title: entry.key,
                                  color: color,
                                  radius: 50,
                                );
                              }).toList(),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Top 5 Incomes
                        const Text("Top 5 Incomes"),
                        ...reportProvider.topIncomes
                            .take(5)
                            .map((r) => ListTile(
                                  title: Text(r.particular),
                                  trailing: Text(
                                      "+₹${r.amount.toStringAsFixed(2)}",
                                      style:
                                          const TextStyle(color: Colors.green)),
                                )),

                        const SizedBox(height: 16),

                        // Top 5 Expenses
                        const Text("Top 5 Expenses"),
                        ...reportProvider.topExpenses
                            .take(5)
                            .map((r) => ListTile(
                                  title: Text(r.particular),
                                  trailing: Text(
                                      "-₹${r.amount.toStringAsFixed(2)}",
                                      style:
                                          const TextStyle(color: Colors.red)),
                                )),
                      ],
                    ),
                  ),
          ),
        );
      },
    );
  }

  Widget _summaryCard(String label, double amount, Color color) {
    return Card(
      elevation: 3,
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("₹${amount.toStringAsFixed(2)}",
                style: TextStyle(fontSize: 16, color: color)),
          ],
        ),
      ),
    );
  }
}
