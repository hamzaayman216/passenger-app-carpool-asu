class PaidStatus {
  bool paid;
  String rideId;
  String userId;
  String userEmail;
  String paymentMethod;

  PaidStatus({
    required this.paid,
    required this.rideId,
    required this.userId,
    required this.userEmail,
    required this.paymentMethod,
  });

  factory PaidStatus.fromMap(Map<String, dynamic> map) {
    return PaidStatus(
      paid: map['paid'] ?? false,
      rideId: map['rideId'] ?? '',
      userId: map['userId'] ?? '',
      userEmail: map['userEmail'] ?? '',
      paymentMethod: map['paymentMethod'] ?? '',
    );
  }
}