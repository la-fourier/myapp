
class Person {
  final String fullName;
  final DateTime dateOfBirth;
  final String? nickname;
  final String? profilePictureUrl;

  Person({
    required this.fullName,
    required this.dateOfBirth,
    this.nickname,
    this.profilePictureUrl,
  });
}
