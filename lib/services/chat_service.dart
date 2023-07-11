import 'dart:convert';

import 'package:chat/global/environment.dart';
import 'package:chat/models/messages_response.dart';
import 'package:chat/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:chat/models/user.dart';

class ChatService with ChangeNotifier {
  late User userFor;

  Future<Message?> sendMessage(Map message) async {
    try {
      final resp = await http.post(Uri.parse('${Environment.apiUrl}/messages/'),
          body: json.encode(message),
          headers: {
            'Content-Type': 'application/json',
          });

      return Message.fromJson(json.decode(resp.body));
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<List<Message>> getChat(String userID, int limit) async {
    final resp = await http.get(
        Uri.parse('${Environment.apiUrl}/messages?from=$userID&limit=${limit}'),
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Credentials': 'true',
          'Access-Control-Allow-Headers': 'Content-Type',
          'Access-Control-Allow-Methods': 'GET,PUT,POST,DELETE',
          'x-token': await AuthService.getToken() ?? ''
        });

    final messagesResponse = messagesResponseFromJson(resp.body);

    return messagesResponse.messages;
  }

  Future<Message?> getLast(String userID) async {
    final resp = await http.get(
        Uri.parse('${Environment.apiUrl}/messages?from=$userID&limit=${1}'),
        headers: {
          'Content-Type': 'application/json',
          'x-token': await AuthService.getToken() ?? ''
        });

    final messagesResponse = messagesResponseFromJson(resp.body);

    return (messagesResponse.messages.isEmpty)
        ? null
        : messagesResponse.messages[0];
  }

  Future<bool> deleteMessage(String messageID) async {
    try {
      var resp = await http.delete(
          Uri.parse('${Environment.apiUrl}/messages/delete/$messageID'));

      var okResponse = json.decode(resp.body);
      return okResponse['ok'];
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> editMessage(Map message) async {
    try {
      var resp = await http.put(
          Uri.parse('${Environment.apiUrl}/messages/edit'),
          headers: {'Content-Type': 'application/json; charset=UTF-8'},
          body: json.encode(message));

      var okResponse = json.decode(resp.body);
      return okResponse['ok'];
    } catch (e) {
      print(e);
      return false;
    }
  }

  void notify() {
    notifyListeners();
  }
}
