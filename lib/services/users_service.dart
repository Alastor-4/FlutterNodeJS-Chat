import 'package:chat/global/environment.dart';
import 'package:chat/models/users_response.dart';
import 'package:chat/services/auth_service.dart';
import 'package:http/http.dart' as http;
import 'package:chat/models/user.dart';

class UsersService {
  Future<List<User>> getUsers() async {
    try {
      final resp =
          await http.get(Uri.parse('${Environment.apiUrl}/users'), headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Credentials': 'true',
        'Access-Control-Allow-Headers': 'Content-Type',
        'Access-Control-Allow-Methods': 'GET,PUT,POST,DELETE',
        'x-token': await AuthService.getToken() ?? ''
      });

      final usersResponse = usersResponseFromJson(resp.body);

      return usersResponse.users;
    } catch (e) {
      return [];
    }
  }
}
