import 'package:equatable/equatable.dart';

abstract class LoginState extends Equatable {
  @override
  List<Object> get props => [];
}

class LoginInitial extends LoginState {}
class LoginLoading extends LoginState {}
class LoginSuccess extends LoginState {}
class LoginFailure extends LoginState {
  final String error;
  LoginFailure(this.error);

  @override
  List<Object> get props => [error];
}

class CredentialsLoaded extends LoginState {
  final String email;
  final String password;
  final bool rememberMe;

  CredentialsLoaded(this.email, this.password, this.rememberMe);

  @override
  List<Object> get props => [email, password, rememberMe];
}