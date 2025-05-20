import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:apartment_manager/provider/credit_payment_provider.dart';

import '../model/credit_model.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class CreditScreen extends StatefulWidget {
  const CreditScreen({super.key});

  @override
  State<CreditScreen> createState() => _CreditScreenState();
}

class _CreditScreenState extends State<CreditScreen> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    Future.microtask(() {
      Provider.of<CreditPaymentProvider>(context, listen: false)
          .loadAllPayments();
    });
  }

  void _onSearch(String query) {
    final provider = Provider.of<CreditPaymentProvider>(context, listen: false);
    if (query.trim().isEmpty) {
      provider.loadAllPayments();
    } else {
      provider.searchPaymentsGlobally(query); // Update this method in provider
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _tableRow(String label, String value) {
    return Column(
      children: [
        Container(
          color: Colors.grey[100],
          child: Row(
            children: [
              Container(
                width: 120,
                color: Colors.grey[300],
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.all(8),
                child: Text(label,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.grey,
                alignment: Alignment.centerLeft,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(value),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }

  Widget _actionButton(String text, VoidCallback onPressed) {
    return Expanded(
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF003366),
          padding: const EdgeInsets.symmetric(vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CreditPaymentProvider>(context);

    return Scaffold(
      backgroundColor: Colors.lightBlue.shade50,
      appBar: AppBar(
        leading: const BackButton(color: Colors.white),
        title: const Text(
          'Credit Payments',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF003366),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            margin: const EdgeInsets.only(bottom: 16),
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 6)
              ],
            ),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search ',
                border: InputBorder.none,
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: _onSearch,
            ),
          ),
          Expanded(
            child: provider.creditPayments.isEmpty
                ? const Center(child: Text('No payments found.'))
                : ListView.builder(
                    itemCount: provider.creditPayments.length,
                    itemBuilder: (context, index) {
                      final payment = provider.creditPayments[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: Column(
                            children: [
                              // Centered Month Header
                              Container(
                                width: double.infinity,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF003366),
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(12),
                                    topRight: Radius.circular(12),
                                  ),
                                ),
                                padding: const EdgeInsets.all(12),
                                child: Center(
                                  child: Text(
                                    payment.month.toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                              // Table-style content with separators
                              _tableRow('Date', payment.date),
                              _tableRow('Receipt No', payment.receiptNo),
                              _tableRow('Paid By', payment.userType),
                              _tableRow('Particulars', payment.particular),
                              _tableRow('Amount',
                                  '₹${payment.amount.toStringAsFixed(2)}'),
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    _actionButton(
                                        'Edit',
                                        () =>
                                            _showEditDialog(context, payment)),
                                    const SizedBox(width: 12),
                                    _actionButton(
                                        'View',
                                        () => _showReceiptDialog(
                                            context, payment)),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

void _generatePdf(CreditPaymentModel payment) async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      build: (pw.Context context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Payment Receipt', style: pw.TextStyle(fontSize: 20)),
          pw.SizedBox(height: 20),
          pw.Text('Month: ${payment.month}'),
          pw.Text('Date: ${payment.date}'),
          pw.Text('Receipt No: ${payment.receiptNo}'),
          pw.Text('Paid By: ${payment.userType}'),
          pw.Text('Particular: ${payment.particular}'),
          pw.Text('Amount: ₹${payment.amount.toStringAsFixed(2)}'),
        ],
      ),
    ),
  );

  await Printing.layoutPdf(
    onLayout: (PdfPageFormat format) async => pdf.save(),
  );
}

void _showEditDialog(BuildContext context, CreditPaymentModel payment) {
  final amountController =
      TextEditingController(text: payment.amount.toString());
  final particularController = TextEditingController(text: payment.particular);
  final dateController = TextEditingController(text: payment.date);

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("Edit Payment"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Read-only receipt no
              TextField(
                controller: TextEditingController(text: payment.receiptNo),
                decoration: const InputDecoration(labelText: "Receipt No"),
                enabled: false,
              ),
              const SizedBox(height: 10),

              // Editable Date field
              TextField(
                controller: dateController,
                decoration: const InputDecoration(
                  labelText: "Date",
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate:
                        DateTime.tryParse(payment.date) ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    dateController.text =
                        "${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year}";
                  }
                },
              ),
              const SizedBox(height: 10),

              TextField(
                controller: particularController,
                decoration: const InputDecoration(labelText: "Particulars"),
              ),
              const SizedBox(height: 10),

              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Amount"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final updatedPayment = CreditPaymentModel(
                id: payment.id,
                apartmentId: payment.apartmentId,
                receiptNo: payment.receiptNo, // read-only
                month: payment.month, // unchanged
                date: dateController.text.trim(),
                particular: particularController.text.trim(),
                amount: double.tryParse(amountController.text.trim()) ?? 0.0,
                userType: payment.userType,
              );

              await Provider.of<CreditPaymentProvider>(context, listen: false)
                  .updatePayment(updatedPayment);
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      );
    },
  );
}

void _showReceiptDialog(BuildContext context, CreditPaymentModel payment) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Payment Receipt'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Month: ${payment.month}'),
            Text('Date: ${payment.date}'),
            Text('Receipt No: ${payment.receiptNo}'),
            Text('Paid By: ${payment.userType}'),
            Text('Particular: ${payment.particular}'),
            Text('Amount: ₹${payment.amount.toStringAsFixed(2)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              _generatePdf(payment);
            },
            child: const Text('Export as PDF'),
          ),
        ],
      );
    },
  );
}
