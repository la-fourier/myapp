class Person {
  final String fullName;
  final DateTime dateOfBirth;
  final String? nickname;
  final String? profilePictureUrl;
  final String? address;
  final String? email;
  final String? password;

  Person({
    required this.fullName,
    required this.dateOfBirth,
    this.nickname,
    this.profilePictureUrl,
    this.address,
    this.email,
    this.password,
  });

  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(
      fullName: json['fullName'],
      dateOfBirth: DateTime.parse(json['dateOfBirth']),
      nickname: json['nickname'],
      profilePictureUrl: json['profilePictureUrl'],
      address: json['address'],
      email: json['email'],
      password: json['password'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'nickname': nickname,
      'profilePictureUrl': profilePictureUrl,
      'address': address,
      'email': email,
      'password': password,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Person &&
          runtimeType == other.runtimeType &&
          fullName == other.fullName &&
          dateOfBirth == other.dateOfBirth;

  @override
  int get hashCode => fullName.hashCode ^ dateOfBirth.hashCode;
}
