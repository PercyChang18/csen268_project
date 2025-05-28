import "package:firebase_auth/firebase_auth.dart" as auth;
import 'package:csen268_project/model/auth_user.dart';

class AuthenticationRepository {
  AuthUser getCurrentUser() {
    auth.User? user = auth.FirebaseAuth.instance.currentUser;
    if (user == null) {
      return AuthUser();
    } else {
      return AuthUser(
        displayName: user.displayName,
        email: user.email,
        imageUrl: user.photoURL,
        uid: user.uid,
        emailVerified: user.emailVerified,
      );
    }
  }

  Future<void> signOut() async {
    await auth.FirebaseAuth.instance.signOut();
  }

  Future<void> verifyEmail() async {
    await auth.FirebaseAuth.instance.currentUser?.sendEmailVerification();
    await auth.FirebaseAuth.instance.signOut();
  }

  Stream<AuthUser> get authUserStream async* {
    await for (final user in auth.FirebaseAuth.instance.authStateChanges()) {
      if (user == null) {
        yield AuthUser();
      } else {
        yield AuthUser(
          email: user.email,
          uid: user.uid,
          imageUrl: user.photoURL,
          displayName: user.displayName,
          emailVerified: user.emailVerified,
        );
      }
    }
  }
}
