class CarPoolUser {
  String name;
  String phoneNumber;
  String email;
  String imageUrl;
  int balance;

  CarPoolUser({required this.name, required this.email, required this.phoneNumber,required this.imageUrl,required this.balance});

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'imageUrl':imageUrl,
      'balance':balance,
    };
  }

  factory CarPoolUser.fromMap(Map<String, dynamic> map) {
    return CarPoolUser(
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      balance:map['balance'] ?? 0,
    );
  }
}