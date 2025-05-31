import 'package:cloud_firestore/cloud_firestore.dart';
import "package:firebase_auth/firebase_auth.dart" as auth;
import 'package:csen268_project/model/auth_user.dart';

class AuthenticationRepository {
  Future<AuthUser?> getCurrentUser() async {
    auth.User? user = auth.FirebaseAuth.instance.currentUser;
    if (user == null) {
      return AuthUser();
    } else {
      final userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();
      bool? hasCompletedWelcome;
      if (userDoc.exists) {
        hasCompletedWelcome = userDoc.data()?['hasCompletedWelcome'];
      }
      return AuthUser(
        displayName: user.displayName,
        email: user.email,
        imageUrl: user.photoURL,
        uid: user.uid,
        emailVerified: user.emailVerified,
        hasCompletedWelcome: hasCompletedWelcome,
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
        final userDoc =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .get();
        bool? hasCompletedWelcome;
        if (userDoc.exists) {
          hasCompletedWelcome = userDoc.data()?['hasCompletedWelcome'];
        }
        yield AuthUser(
          email: user.email,
          uid: user.uid,
          imageUrl: user.photoURL,
          displayName: user.displayName,
          emailVerified: user.emailVerified,
          hasCompletedWelcome: hasCompletedWelcome,
        );
      }
    }
  }
}
