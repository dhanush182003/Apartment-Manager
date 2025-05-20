import 'package:flutter/material.dart';
import 'package:apartment_manager/db/db_helper.dart';
import 'package:apartment_manager/model/apartment_model.dart';

class ApartmentProvider with ChangeNotifier {
  final DBHelper dbHelper = DBHelper();
  List<ApartmentModel> _apartments = [];

  //List<ApartmentModel> get apartments => _apartments;

  List<ApartmentModel> _filteredApartments = [];

  List<ApartmentModel> get apartments =>
      _filteredApartments.isNotEmpty ? _filteredApartments : _apartments;

  // Method to filter apartments based on the search query
  void searchApartments(String query) {
    _filteredApartments = _apartments
        .where((apt) =>
            apt.name.toLowerCase().contains(query.toLowerCase()) ||
            apt.flatNo.contains(query))
        .toList();
    notifyListeners(); // Notify listeners to update the UI
  }

  // Load apartments from DB
  Future<void> loadApartments() async {
    final apartments = await dbHelper.getApartments();
    _apartments = apartments;
    notifyListeners();
  }

  // Add a new apartment
  Future<void> addApartment(ApartmentModel model) async {
    await dbHelper.insertApartment(model);
    await loadApartments(); // Refresh data
  }

  // Update an apartment
  Future<void> updateApartment(ApartmentModel model) async {
    await dbHelper.updateApartment(model);
    await loadApartments(); // Refresh data
  }

  // Delete an apartment
  Future<void> deleteApartment(int id) async {
    await dbHelper.deleteApartment(id);
    await loadApartments(); // Refresh data
  }
}
