import 'package:apartment_manager/provider/report_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:apartment_manager/screens/homescreen.dart';
import 'package:apartment_manager/provider/apartment_provider.dart';
import 'package:apartment_manager/provider/credit_payment_provider.dart';
import 'package:apartment_manager/provider/debit_payment_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ApartmentProvider()),
        ChangeNotifierProvider(create: (_) => CreditPaymentProvider()),
        ChangeNotifierProvider(create: (_) => DebitPaymentProvider()),
        ChangeNotifierProvider(create: (_) => ReportProvider()),
        // Add other providers here if needed
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}
