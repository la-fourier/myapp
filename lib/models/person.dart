class Person {
  final String uid;
  final String fullName;
  final DateTime dateOfBirth;
  final String? nickname;
  final String? profilePictureUrl;
  final String? address;
  final String? email;
  final String? phoneNumber;

  Person({
    required this.uid,
    required this.fullName,
    required this.dateOfBirth,
    this.nickname,
    this.profilePictureUrl,
    this.address,
    this.email,
    this.phoneNumber,
  });

  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(
      uid: json['uid'] ?? '',
      fullName: json['fullName'],
      dateOfBirth: DateTime.parse(json['dateOfBirth']),
      nickname: json['nickname'],
      profilePictureUrl: json['profilePictureUrl'],
      address: json['address'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'fullName': fullName,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'nickname': nickname,
      'profilePictureUrl': profilePictureUrl,
      'address': address,
      'email': email,
      'phoneNumber': phoneNumber,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Person &&
          runtimeType == other.runtimeType &&
          uid == other.uid;

  @override
  int get hashCode => uid.hashCode;
}
