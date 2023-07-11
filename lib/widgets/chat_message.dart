import 'package:chat/services/auth_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class ChatMessage extends StatelessWidget {
  final String id;
  final String text;
  final String uid;
  final AnimationController animationController;
  bool isMyMessage = false;

  ChatMessage(
      {Key? key,
      required this.id,
      required this.text,
      required this.uid,
      this.isMyMessage = true,
      required this.animationController})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    isMyMessage = uid == authService.user!.uid;
    return FadeTransition(
      opacity: animationController,
      child: SizeTransition(
        sizeFactor:
            CurvedAnimation(parent: animationController, curve: Curves.easeOut),
        child: Container(
          child: isMyMessage ? _myMessage() : _notMyMessage(),
        ),
      ),
    );
  }

  Widget _myMessage() {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.all(8),
        margin: const EdgeInsets.only(bottom: 5, left: 50, right: 5),
        child: Text(
          text,
          style: const TextStyle(color: Colors.white),
        ),
        decoration: BoxDecoration(
          color: const Color(0xff4D9EF6),
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  Widget _notMyMessage() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(8),
        margin: const EdgeInsets.only(bottom: 5, right: 50, left: 5),
        child: Text(
          text,
          style: const TextStyle(color: Colors.black87),
        ),
        decoration: BoxDecoration(
          color: const Color(0xffE4E5E8),
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}
