class AuthUser {
  String? displayName;
  String? email;
  String? imageUrl;
  String? uid;
  bool? emailVerified;
  bool? hasCompletedWelcome;

  AuthUser({
    this.displayName,
    this.email,
    this.imageUrl,
    this.uid,
    this.emailVerified,
    this.hasCompletedWelcome,
  });

  bool get isNull {
    if (uid == null) {
      return true;
    }
    return false;
  }
}
