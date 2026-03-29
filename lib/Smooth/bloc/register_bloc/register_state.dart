import 'package:equatable/equatable.dart';

abstract class RegisterState extends Equatable {
  @override
  List<Object> get props => [];
}

class RegisterInitial extends RegisterState {}
class RegisterLoading extends RegisterState {}
class RegisterValidationSuccess extends RegisterState {
  final String name;
  final String email;
  final String password;

  RegisterValidationSuccess({required this.name, required this.email, required this.password});
}
class RegisterFailure extends RegisterState {
  final String error;
  RegisterFailure(this.error);

  @override
  List<Object> get props => [error];
}