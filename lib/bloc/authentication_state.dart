part of 'authentication_bloc.dart';

@immutable
sealed class AuthenticationState {}

final class AuthenticationInitialState extends AuthenticationState {}

final class AuthenticationSignedInState extends AuthenticationState {
  final AuthUser user;
  AuthenticationSignedInState({required this.user});
}

final class AuthenticationNotSignedInState extends AuthenticationState {}

final class AuthenticationVerifyEmailState extends AuthenticationState {}

final class AuthenticationVerifyScreenState extends AuthenticationState {}
