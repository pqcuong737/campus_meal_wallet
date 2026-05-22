import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthStarted extends AuthEvent {
  const AuthStarted();
}

class AuthLoggedIn extends AuthEvent {
  final String id;
  final String password;

  const AuthLoggedIn({ required this.id, required this.password });

  @override
  List<Object?> get props => [id, password];
}

class AuthLoggedOut extends AuthEvent {
  const AuthLoggedOut();
}