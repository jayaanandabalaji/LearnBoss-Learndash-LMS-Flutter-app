import 'base_api.dart';

class AuthApi {
  static login(String username, String password) async {
    var response = await BaseApi.postAsync(
        "jwt-auth/v1/token", {"username": username, "password": password});

    return response;
  }

  static register(String username, String password, String email) async {
    var response = await BaseApi.postAsync("jwt-auth/v1/register",
        {"username": username, "password": password, "email": email});

    return response;
  }

  static resetPassword(String login) async {
    var response = await BaseApi.postAsync("jwt-auth/v1/reset_password", {
      "login": login,
    });

    return response;
  }
}
