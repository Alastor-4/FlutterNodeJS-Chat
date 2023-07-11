import 'package:chat/models/user.dart';
import 'package:chat/services/auth_service.dart';
import 'package:chat/services/chat_service.dart';
import 'package:chat/services/socket_service.dart';
import 'package:chat/services/users_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({Key? key}) : super(key: key);

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  final userService = UsersService();

  List<User> users = [];
  List<String?> _lastMessages = [];

  @override
  void initState() {
    _loadUsers();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final socketService = Provider.of<SocketService>(context);

    final user = authService.user;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          user!.name,
          style: const TextStyle(color: Colors.black54),
        ),
        elevation: 1,
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            socketService.disconnect();
            Navigator.pushReplacementNamed(context, 'login');
            AuthService.deleteToken();
          },
          icon: const Icon(Icons.exit_to_app, color: Colors.black54),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 10),
            child: socketService.serverStatus == ServerStatus.Online
                ? Icon(
                    Icons.check_circle,
                    color: Colors.blue[400],
                  )
                : const Icon(
                    Icons.check_circle,
                    color: Colors.red,
                  ),
          )
        ],
      ),
      body: SmartRefresher(
        controller: _refreshController,
        enablePullDown: true,
        onRefresh: _loadUsers,
        header: WaterDropHeader(
          complete: Icon(
            Icons.check,
            color: Colors.blue[400],
          ),
          waterDropColor: Colors.blue[400]!,
        ),
        child: _listViewUsers(),
      ),
    );
  }

  ListView _listViewUsers() {
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      itemBuilder: (_, i) => _usuarioListTile(users[i], i),
      separatorBuilder: (_, i) => const Divider(),
      itemCount: users.length,
    );
  }

  ListTile _usuarioListTile(User user, int index) {
    return ListTile(
      title: Text(user.name),
      subtitle: Text(user.email +
          '\n' +
          (_lastMessages.isNotEmpty ? _lastMessages[index] ?? '' : '')),
      leading: CircleAvatar(
        child: Text(user.name.substring(0, 2)),
        backgroundColor: Colors.blue[100],
      ),
      trailing: Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
            color: user.online ? Colors.green[300] : Colors.red,
            borderRadius: BorderRadius.circular(100)),
      ),
      onTap: () {
        final chatService = Provider.of<ChatService>(context, listen: false);
        chatService.userFor = user;
        Navigator.pushReplacementNamed(context, 'chat');
      },
    );
  }

  Future<void> asyncFor(
      int index, int max, Future<void> Function(int) forBody) {
    if (index >= max) {
      return Future.value();
    }
    return forBody(index).then((_) => asyncFor(index + 1, max, forBody));
  }

  void _loadUsers() async {
    final chatService = Provider.of<ChatService>(context, listen: false);
    final authService = Provider.of<AuthService>(context, listen: false);
    users = await userService.getUsers();
    _lastMessages.addAll(List.filled(users.length, null));
    await asyncFor(0, users.length, (i) {
      return chatService.getLast(users[i].uid).then((value) {
        if (value != null)
          _lastMessages[i] =
              '${value.from == authService.user!.uid ? 'Tu: ${value.message}' : '${value.message}'}';
      });
    });

    setState(() {});

    _refreshController.refreshCompleted();
  }
}
