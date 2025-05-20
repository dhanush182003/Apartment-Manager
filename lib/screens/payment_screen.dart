import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:apartment_manager/provider/apartment_provider.dart';
import 'package:apartment_manager/screens/payment_reciept.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  @override
  void initState() {
    super.initState();
    // Load apartments from DB when screen loads
    Provider.of<ApartmentProvider>(context, listen: false).loadApartments();
  }

  @override
  Widget build(BuildContext context) {
    final apartmentProvider = Provider.of<ApartmentProvider>(context);
    final apartmentList = apartmentProvider.apartments;

    return Scaffold(
      backgroundColor: Colors.lightBlue.shade50,
      appBar: AppBar(
        backgroundColor: const Color(0xFF003366),
        centerTitle: true,
        title: const Text(
          'Payment',
          style: TextStyle(color: Colors.white),
        ),
        leading: const BackButton(color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Material(
              elevation: 3,
              borderRadius: BorderRadius.circular(12),
              child: TextField(
                onChanged: (value) {
                  apartmentProvider.searchApartments(value);
                },
                decoration: InputDecoration(
                  hintText: 'Search...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: apartmentList.isEmpty
                ? const Center(child: Text("No apartments found."))
                : ListView.builder(
                    itemCount: apartmentList.length,
                    itemBuilder: (context, index) {
                      final data = apartmentList[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        child: Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Table(
                                  border: TableBorder.all(
                                    color: Colors.grey.shade300,
                                    width: 1,
                                  ),
                                  columnWidths: const {
                                    0: FlexColumnWidth(2),
                                    1: FlexColumnWidth(2),
                                  },
                                  children: [
                                    _buildRow("Name", data.name),
                                    _buildRow("Mobile No", data.mobile ?? ''),
                                    _buildRow("Flat No", data.flatNo),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ReceiptScreen(
                                            ownerName: data.name,
                                            mobileNo: data.mobile ?? '',
                                            apartmentNo: data.flatNo,
                                          ),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF003366),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                    ),
                                    child: const Text(
                                      'Payment',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            ),
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

  TableRow _buildRow(String label, String value) {
    return TableRow(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey.shade300),
          bottom: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      children: [
        Container(
          color: Colors.grey.shade200,
          padding: const EdgeInsets.all(12.0),
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF003366),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(12.0),
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF003366),
            ),
          ),
        ),
      ],
    );
  }
}
