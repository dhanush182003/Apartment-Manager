// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:apartment_manager/db/db_helper.dart';
import 'package:apartment_manager/model/credit_model.dart';

class ReceiptScreen extends StatefulWidget {
  final String ownerName;
  final String mobileNo;
  final String apartmentNo;

  const ReceiptScreen({
    super.key,
    required this.ownerName,
    required this.mobileNo,
    required this.apartmentNo,
  });

  @override
  State<ReceiptScreen> createState() => _ReceiptScreenState();
}

class _ReceiptScreenState extends State<ReceiptScreen> {
  final TextEditingController receiptNoController = TextEditingController();
  final TextEditingController dateController =
      TextEditingController(text: "08-04-2025");
  final TextEditingController amountController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _loadNextReceiptNo();
  }

  void _loadNextReceiptNo() async {
    final dbHelper = DBHelper();
    final nextReceipt =
        await dbHelper.getNextReceiptNo(int.parse(widget.apartmentNo));
    setState(() {
      receiptNoController.text = nextReceipt;
    });
  }

  String selectedBillType = 'Maintenance Bill';
  String? selectedMonth = "April";
  String userType = "Owner";
  bool showDropdown = false;
  double totalAmount = 0.0;

  final List<String> billTypes = [
    'Maintenance Bill',
    'Current Bill',
    'Water Bill',
    'Internet Bill',
    'Gas Bill',
    'Rent',
    'Other Bills'
  ];

  void calculateAmount() {
    setState(() {
      totalAmount = double.tryParse(amountController.text) ?? 0.0;
    });
  }

  void resetForm() {
    receiptNoController.clear();
    amountController.clear();
    userType = "Owner";
    totalAmount = 0.0;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue.shade50,
      appBar: AppBar(
        backgroundColor: const Color(0xFF003366),
        centerTitle: true,
        title: const Text(
          "Payment",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Owner Info
            // Owner Info Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              child: Table(
                columnWidths: const {
                  0: FlexColumnWidth(2),
                  1: FlexColumnWidth(2),
                },
                border: TableBorder(
                    horizontalInside: BorderSide(color: Colors.grey.shade300)),
                children: [
                  _styledTableRow("Owner name", widget.ownerName),
                  _styledTableRow("Mobile No", widget.mobileNo),
                  _styledTableRow("Apartment no", widget.apartmentNo),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Form Section
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title + Change Plan
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        selectedBillType,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Color(0xFF003366),
                        ),
                      ),
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF003366),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              showDropdown = !showDropdown;
                            });
                          },
                          child: const Text("Change plan")),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Dropdown for Change Plan
                  if (showDropdown)
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Select Bill Type',
                        border: OutlineInputBorder(),
                      ),
                      value: selectedBillType,
                      items: billTypes.map((String type) {
                        return DropdownMenuItem<String>(
                          value: type,
                          child: Text(type),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            selectedBillType = newValue;
                            showDropdown = false;
                          });
                        }
                      },
                    ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: receiptNoController,
                    decoration: const InputDecoration(
                      labelText: "Receipt no",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),

                  DropdownButtonFormField<String>(
                    value: selectedMonth,
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
                      'December',
                    ].map((String month) {
                      return DropdownMenuItem<String>(
                        value: month,
                        child: Text(month),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedMonth = newValue;
                      });
                    },
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: dateController,
                    decoration: const InputDecoration(
                      labelText: "Date",
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    readOnly: true,
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (pickedDate != null) {
                        String formattedDate =
                            "${pickedDate.day.toString().padLeft(2, '0')}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.year}";
                        setState(() {
                          dateController.text = formattedDate;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    onChanged: (value) => calculateAmount(),
                    decoration: const InputDecoration(
                      labelText: "Amount",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Radio Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildRadioOption("Tenant"),
                      _buildRadioOption("Owner"),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Amount Display
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF003366),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      "${totalAmount.toStringAsFixed(1)} ₹",
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Submit + Reset Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (receiptNoController.text.isEmpty ||
                          amountController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Please fill all required fields")),
                        );
                        return;
                      }

                      final newPayment = CreditPaymentModel(
                        apartmentId: int.parse(widget.apartmentNo),
                        receiptNo: receiptNoController.text.trim(),
                        month: selectedMonth ?? '',
                        date: dateController.text,
                        particular: selectedBillType,
                        amount: double.tryParse(amountController.text.trim()) ??
                            0.0,
                        userType: userType,
                      );

                      final dbHelper =
                          DBHelper(); // Make sure this class is accessible
                      await dbHelper.insertCreditPayment(newPayment);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("Payment saved successfully")),
                      );

                      resetForm();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF003366),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(2),
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5), // sharp edges
                      ), // sets height
                    ),
                    child: const Text("SUBMIT"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: resetForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF003366),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(2),
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5) // sharp edges
                          ), // sets height
                    ),
                    child: const Text("RESET"),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  TableRow _styledTableRow(String label, String value) {
    return TableRow(
      children: [
        Container(
          color: Colors.grey.shade200,
          padding: const EdgeInsets.all(12),
          child: Text(
            label,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(0xFF003366)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            value,
            style: const TextStyle(fontSize: 16, color: Color(0xFF003366)),
          ),
        ),
      ],
    );
  }

  Widget _buildRadioOption(String label) {
    return Row(
      children: [
        Radio<String>(
          value: label,
          groupValue: userType,
          onChanged: (value) {
            setState(() {
              userType = value!;
            });
          },
          activeColor: const Color(0xFF003366),
        ),
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold),
        )
      ],
    );
  }
}
