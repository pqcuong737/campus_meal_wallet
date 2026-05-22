import 'package:equatable/equatable.dart';

enum AuthStatus {
  initial,
  loading, 
  authenticated,
  unauthenticated,
  failure,
}

class AuthState extends Equatable {
  final AuthStatus status;
  final String? errorMessage;

  const AuthState({ required this.status, this.errorMessage });

  const AuthState.initial() : this(status: AuthStatus.initial, errorMessage: null);

  AuthState copyWith({ AuthStatus? status, String? errorMessage }) {
    return AuthState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage];
}