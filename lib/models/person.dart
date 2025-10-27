class Person {
  final String fullName;
  final DateTime dateOfBirth;
  final String? nickname;
  final String? profilePictureUrl;
  final String? address;

  Person({
    required this.fullName,
    required this.dateOfBirth,
    this.nickname,
    this.profilePictureUrl,
    this.address,
  });
}