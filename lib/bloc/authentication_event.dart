part of 'authentication_bloc.dart';

@immutable
sealed class AuthenticationEvent {}

class AuthenticationInitializeEvent extends AuthenticationEvent {
  final AuthenticationRepository authenticationRepository;

  AuthenticationInitializeEvent({required this.authenticationRepository});
}

// sign in and sign out event
class AuthenticationSignInEvent extends AuthenticationEvent {}

class AuthenticationSignOutEvent extends AuthenticationEvent {}

// signed in and signed out event
class AuthenticationSignedInEvent extends AuthenticationEvent {}

class AuthenticationSignedOutEvent extends AuthenticationEvent {}

// request to send email verification
class AuthenticationEmailVerificationRequest extends AuthenticationEvent {}

// cancel the request to send email
class AuthenticationEmailVerificationCancel extends AuthenticationEvent {}

// successfully sent the email screen
class AuthenticationEmailVerificationScreenEvent extends AuthenticationEvent {}

// refresh and get new user data
class AuthenticationRefreshUserEvent extends AuthenticationEvent {}
