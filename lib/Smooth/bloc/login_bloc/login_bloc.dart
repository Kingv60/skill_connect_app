import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../Services/api-service.dart';

import 'login_event.dart';
import 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(LoginInitial()) {

    // Check saved credentials on startup
    on<CheckRememberMe>((event, emit) async {
      final prefs = await SharedPreferences.getInstance();
      final savedEmail = prefs.getString('email') ?? '';
      final savedPassword = prefs.getString('password') ?? '';
      final isRemembered = prefs.getBool('remember_me') ?? false;

      if (isRemembered) {
        emit(CredentialsLoaded(savedEmail, savedPassword, isRemembered));
      }
    });

    // Handle Login Button
    on<LoginSubmitted>((event, emit) async {
      emit(LoginLoading());
      try {
        final apiService = ApiService();
        final response = await apiService.loginUser(event.email, event.password);

        if (response.containsKey("token")) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', ApiService.token!);
          await prefs.setInt('user_id', ApiService.userId!);

          if (event.rememberMe) {
            await prefs.setString('email', event.email);
            await prefs.setString('password', event.password);
            await prefs.setBool('remember_me', true);
          } else {
            await prefs.remove('email');
            await prefs.remove('password');
            await prefs.setBool('remember_me', false);
          }
          emit(LoginSuccess());
        }
      } catch (e) {
        emit(LoginFailure(e.toString()));
      }
    });
  }
}