class Customer {
  final int id;
  final String email;
  final String name;
  final String role;
  final String? phoneNumber;

  const Customer({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.phoneNumber
  });

  factory Customer.fromJson(Map<String, dynamic> json){
    return Customer(
        id: json['id'],
        email: json['email'],
        name: json['name'],
        role: json['role'],
        phoneNumber: json['phone']
    );
  }
}