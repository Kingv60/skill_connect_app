import 'package:flutter_bloc/flutter_bloc.dart';
import 'register_event.dart';
import 'register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  RegisterBloc() : super(RegisterInitial()) {
    on<RegisterSubmitted>((event, emit) async {
      emit(RegisterLoading());

      // Simple validation logic
      if (event.name.isEmpty || event.email.isEmpty || event.password.isEmpty) {
        emit(RegisterFailure("All fields are required"));
        return;
      }

      if (!event.email.contains('@')) {
        emit(RegisterFailure("Please enter a valid email"));
        return;
      }

      // If validation passes, move to next step
      emit(RegisterValidationSuccess(
        name: event.name,
        email: event.email,
        password: event.password,
      ));
    });
  }
}