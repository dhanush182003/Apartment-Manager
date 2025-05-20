import 'package:flutter/material.dart';
import 'package:apartment_manager/db/db_helper.dart';
import 'package:apartment_manager/model/credit_model.dart';
import 'package:apartment_manager/model/debit_payment_model.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final DBHelper dbHelper = DBHelper();
  List<CreditPaymentModel> credits = [];
  List<DebitPayment> debits = [];
  String selectedMonth = 'All';
  String transactionType = 'All';

  double get totalCredit => credits.fold(0.0, (sum, item) => sum + item.amount);
  double get totalDebit => debits.fold(0.0, (sum, item) => sum + item.amount);
  double get balance => totalCredit - totalDebit;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final allCredits = await dbHelper.getAllCreditPayments();
    final allDebits = await dbHelper.getAllDebitPayments();
    setState(() {
      credits = allCredits;
      debits = allDebits;
    });
  }

  List<Map<String, dynamic>> get filteredTransactions {
    final List<Map<String, dynamic>> combined = [
      ...credits.map((e) => {
            'type': 'Credit',
            'date': e.date,
            'month': e.month,
            'particular': e.particular,
            'amount': e.amount
          }),
      ...debits.map((e) => {
            'type': 'Debit',
            'date': e.date,
            'month': e.month,
            'particular': e.particular,
            'amount': e.amount
          }),
    ];

    return combined.where((item) {
      final matchesMonth = selectedMonth == 'All' ||
          item['month'].toString().toLowerCase() == selectedMonth.toLowerCase();
      final matchesType = transactionType == 'All' ||
          item['type'].toString() == transactionType;
      return matchesMonth && matchesType;
    }).toList();
  }

  List<String> months = [
    'All',
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  Future<void> generatePDF() async {
    final pdf = pw.Document();
    final data = filteredTransactions;

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Text('Account Statement',
                  style: const pw.TextStyle(fontSize: 20)),
              pw.SizedBox(height: 10),
              pw.Table.fromTextArray(
                headers: ['Date', 'Particular', 'Credit', 'Debit'],
                data: data
                    .map((tx) => [
                          tx['date'],
                          tx['particular'],
                          tx['type'] == 'Credit' ? '₹${tx['amount']}' : '-',
                          tx['type'] == 'Debit' ? '₹${tx['amount']}' : '-',
                        ])
                    .toList(),
              )
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 188, 217, 239),
      appBar: AppBar(
        title: const Text('Account Statement',
            style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: const Color(0xFF003366),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        const Text('Total Credit',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('₹${totalCredit.toStringAsFixed(2)}'),
                      ],
                    ),
                    Column(
                      children: [
                        const Text('Total Debit',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('₹${totalDebit.toStringAsFixed(2)}'),
                      ],
                    ),
                    Column(
                      children: [
                        const Text('Balance',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('₹${balance.toStringAsFixed(2)}'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedMonth,
                    decoration: const InputDecoration(
                      labelText: 'Month',
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    items: months
                        .map((month) =>
                            DropdownMenuItem(value: month, child: Text(month)))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          selectedMonth = value;
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(Icons.picture_as_pdf),
                  onPressed: generatePDF,
                ),
                // IconButton(
                //   icon: const Icon(Icons.file_download),
                //   onPressed: () {
                //     // TODO: Excel logic here
                //   },
                // ),
              ],
            ),
          ),
          const SizedBox(
            height: 6,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: ['All', 'Credit', 'Debit']
                  .map(
                    (label) => Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: transactionType == label
                              ? const Color(0xFF003366)
                              : Colors.grey[300],
                          foregroundColor: transactionType == label
                              ? Colors.white
                              : Colors.black,
                        ),
                        onPressed: () {
                          setState(() {
                            transactionType = label;
                          });
                        },
                        child: Text(label),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Card(
                color: Colors.white,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      color: const Color(0xFF003366),
                      child: const Row(
                        children: [
                          Expanded(
                              child: Text('Date',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold))),
                          Expanded(
                              child: Text('Particular',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold))),
                          SizedBox(width: 8),
                          Expanded(
                              child: Text('Credit',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold))),
                          Expanded(
                              child: Text('Debit',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold))),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: filteredTransactions.length,
                        itemBuilder: (context, index) {
                          final tx = filteredTransactions[index];
                          final isCredit = tx['type'] == 'Credit';
                          final isDebit = tx['type'] == 'Debit';
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 10),
                            decoration: BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      color: Colors.grey.shade300, width: 1)),
                            ),
                            child: Row(
                              children: [
                                Expanded(child: Text(tx['date'] ?? '')),
                                Expanded(child: Text(tx['particular'] ?? '')),
                                const SizedBox(width: 5),
                                Expanded(
                                  child: Text(
                                    isCredit ? '₹${tx['amount']}' : '',
                                    style: const TextStyle(color: Colors.green),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    isDebit ? '₹${tx['amount']}' : '',
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
