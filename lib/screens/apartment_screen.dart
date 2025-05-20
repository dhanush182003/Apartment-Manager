// ignore_for_file: use_build_context_synchronously

import 'package:apartment_manager/model/apartment_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:apartment_manager/provider/apartment_provider.dart';

class ApartmentScreen extends StatefulWidget {
  const ApartmentScreen({super.key});
  @override
  State<ApartmentScreen> createState() => _ApartmentScreenState();
}

class _ApartmentScreenState extends State<ApartmentScreen> {
  @override
  void initState() {
    super.initState();
    // Load apartments when the screen is initialized
    Future.microtask(() => context.read<ApartmentProvider>().loadApartments());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue.shade50,
      appBar: AppBar(
        leading: const BackButton(color: Colors.white),
        title: const Text(
          'Apartment',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF003366),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Search bar section
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
                onChanged: (query) {
                  context.read<ApartmentProvider>().searchApartments(query);
                },
                decoration: const InputDecoration(
                  hintText: 'Search...',
                  border: InputBorder.none,
                  suffixIcon: Icon(Icons.search, color: Color(0xFF003366)),
                ),
              ),
            ),
            // Apartment list section
            Expanded(
              child: Consumer<ApartmentProvider>(
                builder: (context, provider, child) {
                  final apartments = provider.apartments;
                  return ListView.builder(
                    itemCount: apartments.length,
                    itemBuilder: (context, i) {
                      final apartment = apartments[i];
                      return _ApartmentCard(
                        name: apartment.name,
                        mobileNo: apartment.mobile ?? '',
                        flatNo: apartment.flatNo,
                        onEdit: () {
                          showDialog(
                            context: context,
                            builder: (_) => buildEditDialog(
                              context,
                              apartment,
                              context.read<ApartmentProvider>().updateApartment,
                            ),
                          );
                        },
                        onDelete: () {
                          showDialog(
                            context: context,
                            builder: (_) => buildDeleteConfirmationDialog(
                              context,
                              apartment.id!,
                              apartment.flatNo,
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF003366),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => buildAddOwnerDialog(
              context,
              context.read<ApartmentProvider>().addApartment,
            ),
          );
        },
      ),
    );
  }
}

class _ApartmentCard extends StatelessWidget {
  final String name, mobileNo, flatNo;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _ApartmentCard({
    required this.name,
    required this.mobileNo,
    required this.flatNo,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        children: [
          Table(
            columnWidths: const {
              0: FlexColumnWidth(1),
              1: FlexColumnWidth(1),
            },
            border: TableBorder(
                horizontalInside: BorderSide(color: Colors.grey.shade500)),
            children: [
              _buildRow('Name', name),
              _buildRow('Mobile No', mobileNo),
              _buildRow('Flat No', flatNo),
            ],
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF003366),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6)),
                    ),
                    onPressed: onEdit,
                    child: const Text('Edit'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF003366),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6)),
                    ),
                    onPressed: onDelete,
                    child: const Text('Delete'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  TableRow _buildRow(String label, String value) {
    return TableRow(children: [
      Container(
        color: Colors.grey.shade200,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Text(
          label,
          style: const TextStyle(
            color: Color(0xFF003366),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Text(
          value,
          style: const TextStyle(
            color: Color(0xFF003366),
          ),
        ),
      ),
    ]);
  }
}

Widget buildEditDialog(BuildContext context, ApartmentModel model,
    Function(ApartmentModel) onUpdate) {
  TextEditingController nameController =
      TextEditingController(text: model.name);
  TextEditingController flatController =
      TextEditingController(text: model.flatNo);
  TextEditingController mobileController =
      TextEditingController(text: model.mobile ?? '');
  TextEditingController emailController =
      TextEditingController(text: model.email ?? '');
  TextEditingController tenantNameController =
      TextEditingController(text: model.tenantName ?? '');
  TextEditingController tenantEmailController =
      TextEditingController(text: model.tenantEmail ?? '');
  String selectedRole = model.role ?? 'Owner';

  return StatefulBuilder(
    builder: (context, setState) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.all(20),
        title: const Text(
          "Update Apartment Details",
          style:
              TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF003366)),
        ),
        content: SingleChildScrollView(
          child: Column(
            children: [
              _buildInputField(
                  controller: nameController, icon: Icons.person, hint: "Name"),
              const SizedBox(height: 10),
              _buildInputField(
                  controller: flatController,
                  icon: Icons.home,
                  hint: "Flat No"),
              const SizedBox(height: 10),
              _buildInputField(
                  controller: mobileController,
                  icon: Icons.phone,
                  hint: "Mobile"),
              const SizedBox(height: 10),
              _buildInputField(
                  controller: emailController,
                  icon: Icons.email,
                  hint: "Email"),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile(
                      title: const Text("Tenant",
                          style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF003366),
                              fontWeight: FontWeight.bold)),
                      value: "Tenant",
                      groupValue: selectedRole,
                      onChanged: (value) =>
                          setState(() => selectedRole = value.toString()),
                    ),
                  ),
                  Expanded(
                    child: RadioListTile(
                      title: const Text("Owner",
                          style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF003366),
                              fontWeight: FontWeight.bold)),
                      value: "Owner",
                      groupValue: selectedRole,
                      onChanged: (value) =>
                          setState(() => selectedRole = value.toString()),
                    ),
                  ),
                ],
              ),
              if (selectedRole == "Tenant") ...[
                const SizedBox(height: 10),
                _buildInputField(
                    controller: tenantNameController,
                    icon: Icons.person_outline,
                    hint: "Tenant Name"),
                const SizedBox(height: 10),
                _buildInputField(
                    controller: tenantEmailController,
                    icon: Icons.email_outlined,
                    hint: "Tenant Email"),
              ],
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF003366),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () async {
                        final updatedModel = ApartmentModel(
                          id: model.id,
                          name: nameController.text.trim(),
                          flatNo: flatController.text.trim(),
                          mobile: mobileController.text.trim(),
                          email: emailController.text.trim(),
                          role: selectedRole,
                          tenantName: tenantNameController.text.trim(),
                          tenantEmail: tenantEmailController.text.trim(),
                        );
                        // Call the onUpdate function with the updated model
                        onUpdate(updatedModel);
                        Navigator.pop(context);
                      },
                      child: const Text("UPDATE",
                          style: TextStyle(
                              fontWeight: FontWeight.w300,
                              color: Colors.white)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: const Color(0xFF003366),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        side: const BorderSide(
                            color: Color(0xFF003366), width: 1.5),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text("RESET",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w300)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

// Widget _buildInputField({
//   required TextEditingController controller,
//   required IconData icon,
//   required String hint,
// }) {
//   return TextField(
//     controller: controller,
//     decoration: InputDecoration(
//       prefixIcon: Icon(icon),
//       hintText: hint,
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(8),
//         borderSide: BorderSide(color: Colors.grey),
//       ),
//     ),
//   );
// }
Widget buildDeleteConfirmationDialog(
    BuildContext context, int id, String flatNo) {
  return AlertDialog(
    title: Text(
      "Delete Flat No: $flatNo?",
      style: const TextStyle(fontWeight: FontWeight.bold),
      textAlign: TextAlign.center,
    ),
    content: Text("Are you sure you want to delete this Flat No: $flatNo?"),
    actions: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Provider.of<ApartmentProvider>(context, listen: false)
                  .deleteApartment(id); // Call Provider method
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text("Delete"),
          ),
        ],
      )
    ],
  );
}

Widget buildAddOwnerDialog(
    BuildContext context, Function(ApartmentModel) onAdd) {
  TextEditingController nameController = TextEditingController();
  TextEditingController flatController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController tenantNameController = TextEditingController();
  TextEditingController tenantEmailController = TextEditingController();

  String selectedRole = 'Owner';

  return StatefulBuilder(
    builder: (context, setState) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.all(20),
        title: const Text(
          "Add Apartment Details",
          style:
              TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF003366)),
        ),
        content: SingleChildScrollView(
          child: Column(
            children: [
              _buildInputField(
                  controller: nameController, icon: Icons.person, hint: "Name"),
              const SizedBox(height: 10),
              _buildInputField(
                  controller: flatController,
                  icon: Icons.home,
                  hint: "Flat No"),
              const SizedBox(height: 10),
              _buildInputField(
                  controller: mobileController,
                  icon: Icons.phone,
                  hint: "Mobile"),
              const SizedBox(height: 10),
              _buildInputField(
                  controller: emailController,
                  icon: Icons.email,
                  hint: "Email"),
              const SizedBox(height: 10),

              // Role selector
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      value: 'Tenant',
                      groupValue: selectedRole,
                      title: const Text('Tenant',
                          style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF003366),
                              fontWeight: FontWeight.bold)),
                      onChanged: (value) =>
                          setState(() => selectedRole = value!),
                      activeColor: const Color(0xFF003366),
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      value: 'Owner',
                      groupValue: selectedRole,
                      title: const Text('Owner',
                          style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF003366),
                              fontWeight: FontWeight.bold)),
                      onChanged: (value) =>
                          setState(() => selectedRole = value!),
                      activeColor: const Color(0xFF003366),
                    ),
                  ),
                ],
              ),

              if (selectedRole == 'Tenant') ...[
                _buildInputField(
                    controller: tenantNameController,
                    icon: Icons.person,
                    hint: "Tenant Name"),
                const SizedBox(height: 10),
                _buildInputField(
                    controller: tenantEmailController,
                    icon: Icons.email,
                    hint: "Tenant Email"),
              ],

              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF003366),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () async {
                        final apartment = ApartmentModel(
                          name: nameController.text.trim(),
                          flatNo: flatController.text.trim(),
                          mobile: mobileController.text.trim(),
                          email: emailController.text.trim(),
                          role: selectedRole,
                          tenantName: tenantNameController.text.trim(),
                          tenantEmail: tenantEmailController.text.trim(),
                        );

                        // Call the onAdd function to add the apartment
                        onAdd(apartment); // Callback to insert + refresh UI
                        // Close the dialog after adding the apartment
                        Navigator.pop(context);
                      },
                      child: const Text("SUBMIT",
                          style: TextStyle(
                              fontWeight: FontWeight.w300,
                              color: Colors.white)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: const Color(0xFF003366),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(
                            color: Color(0xFF003366), width: 1.5),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {
                        // Clear all input fields and reset role to 'Owner'
                        nameController.clear();
                        flatController.clear();
                        mobileController.clear();
                        emailController.clear();
                        tenantNameController.clear();
                        tenantEmailController.clear();
                        setState(() => selectedRole = 'Owner');
                      },
                      child: const Text(
                        "RESET",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

Widget _buildInputField({
  required TextEditingController controller,
  required IconData icon,
  required String hint,
}) {
  return TextField(
    controller: controller,
    style: const TextStyle(color: Color(0xFF003366)),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF003366)),
      prefixIcon: Icon(icon, color: const Color(0xFF003366)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF003366), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF003366), width: 2),
      ),
    ),
  );
}
