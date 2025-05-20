class ApartmentModel {
  int? id; // id is nullable because it will be auto-generated
  String flatNo;
  String name;
  String? mobile;
  String? email;
  String? role;
  String? tenantName;
  String? tenantEmail;

  ApartmentModel({
    this.id,
    required this.flatNo,
    required this.name,
    this.mobile,
    this.email,
    this.role,
    this.tenantName,
    this.tenantEmail,
  });

  // Convert a ApartmentModel into a Map (for inserting/updating)
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'flatNo': flatNo,
      'name': name,
      'mobile': mobile,
      'email': email,
      'role': role,
      'tenantName': tenantName,
      'tenantEmail': tenantEmail,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  // Create a ApartmentModel from a Map (for fetching from DB)
  factory ApartmentModel.fromMap(Map<String, dynamic> map) {
    return ApartmentModel(
      id: map['id'],
      flatNo: map['flatNo'],
      name: map['name'],
      mobile: map['mobile'],
      email: map['email'],
      role: map['role'],
      tenantName: map['tenantName'],
      tenantEmail: map['tenantEmail'],
    );
  }
}
