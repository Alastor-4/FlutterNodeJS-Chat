// To parse this JSON data, do
//
//     final messagesResponse = messagesResponseFromJson(jsonString);

import 'dart:convert';

MessagesResponse messagesResponseFromJson(String str) =>
    MessagesResponse.fromJson(json.decode(str));

String messagesResponseToJson(MessagesResponse data) =>
    json.encode(data.toJson());

class MessagesResponse {
  MessagesResponse({
    required this.ok,
    required this.myId,
    required this.messages,
  });

  bool ok;
  String myId;
  List<Message> messages;

  factory MessagesResponse.fromJson(Map<String, dynamic> json) =>
      MessagesResponse(
        ok: json["ok"],
        myId: json["myId"],
        messages: List<Message>.from(
            json["messages"].map((x) => Message.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "ok": ok,
        "myId": myId,
        "messages": List<dynamic>.from(messages.map((x) {
          return x.toJson();
        })),
      };
}

class Message {
  Message({
    required this.id,
    required this.from,
    required this.to,
    required this.message,
    required this.createdAt,
    required this.updatedAt,
  });

  String id;
  String from;
  String to;
  String message;
  DateTime createdAt;
  DateTime updatedAt;

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        id: json["uid"],
        from: json["from"],
        to: json["to"],
        message: json["message"],
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
      );

  Map<String, dynamic> toJson() => {
        "uid": id,
        "from": from,
        "to": to,
        "message": message,
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
      };
}
