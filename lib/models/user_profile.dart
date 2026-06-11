class UserProfile {
  const UserProfile({
    required this.uid,
    required this.email,
    required this.role,
    this.fullName,
    this.studentId,
    this.phoneNumber,
    this.university,
  });

  final String uid;
  final String email;
  final String role;
  final String? fullName;
  final String? studentId;
  final String? phoneNumber;
  final String? university;

  factory UserProfile.fromMap(
    String uid,
    Map<String, dynamic> data, {
    String? phoneNumber,
  }) {
    return UserProfile(
      uid: uid,
      email: (data['email'] as String?) ?? '',
      role: (data['role'] as String?) ?? '',
      fullName: data['fullName'] as String?,
      studentId: data['studentId'] as String?,
      university: data['university'] as String?,
      phoneNumber: phoneNumber,
    );
  }
}
