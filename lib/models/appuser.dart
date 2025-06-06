class AppUser {
  final String uid;
  final String? email;
  final String? displayName;
  final String? photoURL;
  final String? fcmToken;
  final DateTime? lastLogin;

  AppUser({
    required this.uid,
    this.email,
    this.displayName,
    this.photoURL,
    this.fcmToken,
    this.lastLogin,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      uid: json['uid'],
      email: json['email'],
      displayName: json['displayName'],
      photoURL: json['photoURL'],
      fcmToken: json['fcmToken'],
      lastLogin: json['lastLogin'] != null
          ? DateTime.tryParse(json['lastLogin'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'fcmToken': fcmToken,
      'lastLogin': lastLogin?.toIso8601String(),
    };
  }
}
