import 'package:shared_preferences/shared_preferences.dart';
import '../../../Services/api-service.dart';

class AuthRepository {
  final ApiService _apiService = ApiService();

  Future<bool> login(String email, String password, bool rememberMe) async {
    final response = await _apiService.loginUser(email, password);

    if (response.containsKey("token")) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', ApiService.token!);
      await prefs.setInt('user_id', ApiService.userId!);

      if (rememberMe) {
        await prefs.setString('email', email);
        await prefs.setString('password', password);
        await prefs.setBool('remember_me', true);
      } else {
        await prefs.remove('email');
        await prefs.remove('password');
        await prefs.setBool('remember_me', false);
      }
      return true;
    }
    return false;
  }
}