import 'package:flutter/material.dart';
import 'package:apartment_manager/screens/apartment_screen.dart';
import 'package:apartment_manager/screens/creditscreen.dart';
import 'package:apartment_manager/screens/payment_screen.dart';
// import 'package:apartment_manager/screens/reportscreen.dart';
import 'package:apartment_manager/screens/debit_screen.dart';
import 'package:apartment_manager/screens/account_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue.shade50,
      appBar: AppBar(
        title: const Text(
          'Apartment Manager',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF003366),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Welcome Back Section with Background Image
            Container(
              width: double.infinity,
              height: 140,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.blue.shade200,
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                  image: const NetworkImage(
                    'https://thumbs.dreamstime.com/b/apartment-building-19532951.jpg',
                  ),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.3),
                    BlendMode.darken,
                  ),
                ),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Welcome Back',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Building name',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Grid Section
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 1.1,
                children: [
                  _buildGridItem(context, 'Apartment', Icons.apartment,
                      const ApartmentScreen()),
                  _buildGridItem(
                      context, 'Payment', Icons.payment, const PaymentScreen()),
                  _buildGridItem(context, 'Credit', Icons.credit_card,
                      const CreditScreen()),
                  _buildGridItem(
                      context, 'Debit', Icons.credit_card, const DebitScreen()),
                  _buildGridItem(context, 'Account', Icons.account_balance,
                      const AccountScreen()),
                  // _buildGridItem(
                  //     context, 'Report', Icons.report, const ReportScreen()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Grid Item with icon
  Widget _buildGridItem(
      BuildContext context, String title, IconData icon, Widget screen) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 5,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 40, color: const Color(0xFF003366)),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF003366),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
