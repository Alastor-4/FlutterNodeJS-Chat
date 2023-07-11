import 'package:chat/pages/login_page.dart';
import 'package:chat/pages/users_page.dart';
import 'package:chat/services/auth_service.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:chat/services/socket_service.dart';

class LoadingPage extends StatelessWidget {
  const LoadingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: checkLoginState(context),
        builder: (context, snapshot) {
          return const Center(
            child: Text("Autenticando..."),
          );
        },
      ),
    );
  }

  Future checkLoginState(BuildContext context) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final socketService = Provider.of<SocketService>(context);

    final authenticating = await authService.isLoggedIn();

    if (authenticating) {
      socketService.connect();
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const UsersPage(),
          transitionDuration: const Duration(milliseconds: 0),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const LoginPage(),
          transitionDuration: const Duration(milliseconds: 0),
        ),
      );
    }
  }
}
