import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:csen268_project/repositories/authentication/authentication.dart';
import 'package:csen268_project/services/mock.dart';
import 'package:csen268_project/model/auth_user.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'authentication_event.dart';
part 'authentication_state.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  AuthenticationBloc() : super(AuthenticationInitialState()) {
    on<AuthenticationInitializeEvent>((event, emit) {
      init(event, emit);
    });

    on<AuthenticationSignInEvent>((event, emit) {
      // manual sign in
    });
    on<AuthenticationSignOutEvent>((event, emit) {
      signOut(event, emit);
    });

    on<AuthenticationSignedInEvent>((event, emit) {
      emit(AuthenticationSignedInState(user: user!));
    });
    on<AuthenticationSignedOutEvent>((event, emit) {
      emit(AuthenticationNotSignedInState());
    });
    // email verification request
    on<AuthenticationEmailVerificationRequest>((event, emit) {
      verifyEmail(event, emit);
    });
    // cancel the verification of email -> still signed in
    on<AuthenticationEmailVerificationCancel>((event, emit) {
      emit(AuthenticationSignedInState(user: user!));
    });
    // send the verification of email screen
    on<AuthenticationEmailVerificationScreenEvent>((event, emit) {
      emit(AuthenticationVerifyScreenState());
    });
    // Re-fetch the current user data from the repository
    on<AuthenticationRefreshUserEvent>((event, emit) async {
      final AuthUser? refreshedUser =
          await authenticationRepository.getCurrentUser();
      if (refreshedUser != null && !refreshedUser.isNull) {
        updateUser(refreshedUser); // Use the existing updateUser logic
      } else {
        add(AuthenticationSignedOutEvent());
      }
    });
  }

  late final AuthenticationRepository authenticationRepository;
  AuthUser? user;
  StreamSubscription<AuthUser>? authUserStream;

  void init(AuthenticationInitializeEvent event, emit) {
    authenticationRepository = event.authenticationRepository;
    authUserStream = authenticationRepository.authUserStream.listen((
      AuthUser user,
    ) {
      if (user.isNull || user.email == null || user.uid == null) {
        // if the user is null, or not having email/ uid, sign them out
        add(AuthenticationSignedOutEvent());
      } else {
        // else, update the user
        updateUser(user);
      }
    });
  }

  void signOut(event, emit) {
    emit(AuthenticationNotSignedInState());
    user = null;
    authenticationRepository.signOut();
  }

  void updateUser(AuthUser authUser) {
    user = AuthUser(
      displayName: authUser.displayName ?? "",
      email: authUser.email!,
      uid: authUser.uid!,
      imageUrl: authUser.imageUrl ?? Mock.imageUrl(),
      emailVerified: authUser.emailVerified ?? false,
      hasCompletedWelcome: authUser.hasCompletedWelcome ?? false,
    );
    if (user!.emailVerified == false) {
      // if not verified the email, send them to the verification screen
      add(AuthenticationEmailVerificationScreenEvent());
    } else {
      add(AuthenticationSignedInEvent());
    }
  }

  void verifyEmail(event, emit) {
    emit(AuthenticationVerifyEmailState());
    authenticationRepository.verifyEmail();
  }

  @override
  Future<void> close() {
    authUserStream?.cancel();
    return super.close();
  }
}
