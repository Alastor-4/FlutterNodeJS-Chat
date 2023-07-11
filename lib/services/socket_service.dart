// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';
// ignore: library_prefixes
import 'package:socket_io_client/socket_io_client.dart' as IO;

import 'package:chat/global/environment.dart';
import 'package:chat/services/auth_service.dart';

enum ServerStatus { Online, Offline, Connecting }

class SocketService with ChangeNotifier {
  ServerStatus _serverStatus = ServerStatus.Connecting;
  late IO.Socket _socket;

  ServerStatus get serverStatus => _serverStatus;

  IO.Socket get socket => _socket;
  Function get emit => _socket.emit;

  void connect() async {
    final token = await AuthService.getToken();

    // Dart client
    _socket = IO.io(Environment.socketUrl, {
      'transports': ['websocket'],
      'autoConnect': true,
      'forceNew': true,
      'extraHeaders': {'x-token': token}
    });

    _socket.onConnect((_) {
      _serverStatus = ServerStatus.Online;
      print('Online');
      notifyListeners();
    });

    _socket.onDisconnect((_) {
      _serverStatus = ServerStatus.Offline;
      print('Offline');
      notifyListeners();
    });
  }

  void disconnect() {
    _socket.disconnect();
  }
}
