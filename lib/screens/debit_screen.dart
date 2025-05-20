// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/debit_payment_model.dart';
import '../provider/debit_payment_provider.dart';
import 'package:apartment_manager/db/db_helper.dart';
// import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class DebitScreen extends StatefulWidget {
  const DebitScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _DebitScreenState createState() => _DebitScreenState();
}

class _DebitScreenState extends State<DebitScreen> {
  String? selectedParticular;
  String? paymentMode;
  final TextEditingController dateController = TextEditingController();
  final TextEditingController monthController = TextEditingController();
  final TextEditingController voucherNoController = TextEditingController();
  final TextEditingController paidToController = TextEditingController();
  final TextEditingController mobileNoController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController remarksController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final provider =
          Provider.of<DebitPaymentProvider>(context, listen: false);
      await provider.loadAllPayments();

      final nextVoucher = await provider.getNextVoucherNumber();
      setState(() {
        voucherNoController.text = nextVoucher;
      });
    });
  }

  void resetForm() {
    monthController.clear();
    voucherNoController.clear();
    dateController.clear();
    selectedParticular = null;
    paidToController.clear();
    mobileNoController.clear();
    amountController.clear();
    paymentMode = null;
    remarksController.clear();
    setState(() {});
  }

  void submitForm() async {
    final newPayment = DebitPayment(
      apartmentId: 1, // Dummy ID for now
      month: monthController.text,
      voucherNo: voucherNoController.text,
      date: dateController.text,
      particular: selectedParticular ?? '',
      paidTo: paidToController.text,
      mobileNo: mobileNoController.text,
      amount: double.tryParse(amountController.text) ?? 0.0,
      paymentMode: paymentMode ?? '',
      remarks: remarksController.text,
    );

    await Provider.of<DebitPaymentProvider>(context, listen: false)
        .addPayment(newPayment);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Debit entry saved')),
    );
    resetForm();
  }

  Widget buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget buildRow(String label, String value) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(10),
              color: Colors.grey.shade300,
              child: Text(label,
                  style: const TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(10),
              color: Colors.white,
              child: Text(value),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DebitPaymentProvider>(context);

    return Scaffold(
      backgroundColor: Colors.lightBlue.shade50,
      appBar: AppBar(
        title: const Text('Debit Vouchers'),
        backgroundColor: const Color(0xFF003366),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            Container(
              color: const Color(0xFF003366),
              child: const TabBar(
                indicatorColor: Colors.white,
                labelColor: Color(0xFF003366),
                unselectedLabelColor: Colors.white,
                tabs: [
                  Tab(
                      child: Text('Debits Entry',
                          style: TextStyle(color: Colors.white))),
                  Tab(
                      child:
                          Text('View', style: TextStyle(color: Colors.white))),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [buildEntryForm(), buildViewList(provider)],
              ),
            )
          ],
        ),
      ),
    );
  }

  void showEditDialog(DebitPayment debit) {
    final TextEditingController monthController =
        TextEditingController(text: debit.month);
    final TextEditingController dateController =
        TextEditingController(text: debit.date);
    final TextEditingController particularController =
        TextEditingController(text: debit.particular);
    final TextEditingController amountController =
        TextEditingController(text: debit.amount.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Debit Entry'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: monthController,
                decoration: const InputDecoration(labelText: 'Month'),
              ),
              TextField(
                controller: dateController,
                decoration: const InputDecoration(labelText: 'Date'),
              ),
              TextField(
                controller: particularController,
                decoration: const InputDecoration(labelText: 'Particular'),
              ),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Amount'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text('Save'),
            onPressed: () async {
              final updated = debit.copyWith(
                month: monthController.text,
                date: dateController.text,
                particular: particularController.text,
                amount: double.tryParse(amountController.text) ?? 0.0,
              );

              await DBHelper().updateDebitPayment(updated);
              Navigator.pop(context);
              setState(() {}); // reloads UI
            },
          ),
        ],
      ),
    );
  }

  void showReceiptDialog(DebitPayment debit) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Debit Receipt"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _receiptRow("Voucher No", debit.voucherNo),
            _receiptRow("Month", debit.month),
            _receiptRow("Date", debit.date),
            _receiptRow("Particular", debit.particular),
            _receiptRow("Paid To", debit.paidTo),
            _receiptRow("Mobile No", debit.mobileNo),
            _receiptRow("Amount", "₹${debit.amount.toStringAsFixed(2)}"),
            _receiptRow("Payment Mode", debit.paymentMode),
            _receiptRow("Remarks", debit.remarks),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
          ElevatedButton(
            onPressed: () {
              exportReceiptAsPdf(debit);
              Navigator.pop(context);
            },
            child: const Text("Export as PDF"),
          ),
        ],
      ),
    );
  }

  Widget _receiptRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("$label:", style: const TextStyle(fontWeight: FontWeight.bold)),
          Flexible(child: Text(value, textAlign: TextAlign.right)),
        ],
      ),
    );
  }

  void exportReceiptAsPdf(DebitPayment debit) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Debit Receipt',
                style:
                    pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            _pdfRow('Voucher No', debit.voucherNo),
            _pdfRow('Month', debit.month),
            _pdfRow('Date', debit.date),
            _pdfRow('Particular', debit.particular),
            _pdfRow('Paid To', debit.paidTo),
            _pdfRow('Mobile No', debit.mobileNo),
            _pdfRow('Amount', "₹${debit.amount.toStringAsFixed(2)}"),
            _pdfRow('Payment Mode', debit.paymentMode),
            _pdfRow('Remarks', debit.remarks),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  pw.Widget _pdfRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text("$label:",
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.Text(value),
        ],
      ),
    );
  }

  Widget buildEntryForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            value:
                monthController.text.isNotEmpty ? monthController.text : null,
            decoration: const InputDecoration(
              labelText: 'Month',
              border: OutlineInputBorder(),
            ),
            items: [
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
              'December'
            ]
                .map((month) =>
                    DropdownMenuItem(value: month, child: Text(month)))
                .toList(),
            onChanged: (value) {
              setState(() {
                monthController.text = value!;
              });
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: voucherNoController,
            readOnly: true,
            decoration: const InputDecoration(
              labelText: 'Voucher No',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: dateController,
            readOnly: true,
            decoration: const InputDecoration(
              labelText: 'Date',
              border: OutlineInputBorder(),
            ),
            onTap: () async {
              final pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (pickedDate != null) {
                setState(() {
                  dateController.text =
                      "${pickedDate.day}-${pickedDate.month}-${pickedDate.year}";
                });
              }
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: selectedParticular,
            decoration: const InputDecoration(
              labelText: 'Select Particular',
              border: OutlineInputBorder(),
            ),
            items: ['Electricity', 'Supplies', 'Misc']
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (value) => setState(() => selectedParticular = value),
          ),
          const SizedBox(height: 16),
          buildTextField('Paid to', paidToController),
          buildTextField('Mobile No', mobileNoController),
          buildTextField('Amount', amountController),
          DropdownButtonFormField<String>(
            value: paymentMode,
            decoration: const InputDecoration(
              labelText: 'Payment Mode',
              border: OutlineInputBorder(),
            ),
            items: ['Cash', 'Online', 'Cheque']
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (value) => setState(() => paymentMode = value),
          ),
          const SizedBox(height: 16),
          buildTextField('Remarks', remarksController),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF003366),
                    padding: const EdgeInsets.all(2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5), // sharp edges
                    ),
                  ),
                  child: const Text('Submit',
                      style: TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: resetForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF003366),
                    padding: const EdgeInsets.all(2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5), // sharp edges
                    ),
                  ),
                  child: const Text('Reset',
                      style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget buildViewList(DebitPaymentProvider provider) {
    return ListView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: provider.debitPayments.length,
      itemBuilder: (context, index) {
        final item = provider.debitPayments[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 10),
          elevation: 3,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Column(
            children: [
              buildRow('ID', item.id?.toString() ?? ''),
              buildRow('Month', item.month),
              buildRow('Date', item.date),
              buildRow('Particular', item.particular),
              buildRow('Amount', item.amount.toStringAsFixed(2)),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        showEditDialog(item);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF003366),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Edit',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        showReceiptDialog(item);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF003366),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('View',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }
}
