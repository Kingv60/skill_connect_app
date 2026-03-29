import 'package:equatable/equatable.dart';

abstract class LoginEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class CheckRememberMe extends LoginEvent {}

class LoginSubmitted extends LoginEvent {
  final String email;
  final String password;
  final bool rememberMe;

  LoginSubmitted({required this.email, required this.password, required this.rememberMe});

  @override
  List<Object> get props => [email, password, rememberMe];
}