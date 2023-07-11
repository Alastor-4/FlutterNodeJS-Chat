import 'dart:io' as io;

import 'package:chat/models/messages_response.dart';
import 'package:chat/services/auth_service.dart';
import 'package:chat/services/chat_service.dart';
import 'package:chat/services/socket_service.dart';
import 'package:chat/widgets/chat_message.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:pull_to_refresh/pull_to_refresh.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with TickerProviderStateMixin {
  final _textController = TextEditingController();
  final _focusNode = FocusNode();

  // final RefreshController _refreshController =
  //     RefreshController(initialRefresh: false);

  late ChatService chatService;
  late SocketService socketService;
  late AuthService authService;

  List<ChatMessage> _messages = [];

  bool _isWrite = false;

  int limit = 30;

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
    chatService = Provider.of<ChatService>(context, listen: false);
    socketService = Provider.of<SocketService>(context, listen: false);
    authService = Provider.of<AuthService>(context, listen: false);

    socketService.socket.on('personal-message', _listenMessage);
    socketService.socket.on('delete-message', _deleteMessage);
    socketService.socket.on('edit-message', _editMessage);

    _loadHistory(chatService.userFor.uid);
  }

  void _loadHistory(String userID) async {
    List<Message> chat = await chatService.getChat(userID, limit);

    final history = chat.map((m) => ChatMessage(
          id: m.id,
          text: m.message,
          uid: m.from,
          isMyMessage: authService.user!.uid == m.from,
          animationController: AnimationController(
              vsync: this, duration: const Duration(milliseconds: 0))
            ..forward(),
        ));

    setState(() {
      _messages.insertAll(0, history);
    });
  }

  void _listenMessage(dynamic payload) {
    ChatMessage message = ChatMessage(
      id: payload['uid'],
      text: payload['message'],
      uid: payload['from'],
      animationController: AnimationController(
          vsync: this, duration: const Duration(milliseconds: 300)),
    );

    setState(() {
      _messages.insert(0, message);
    });

    message.animationController.forward();
  }

  void _deleteMessage(data) {
    print(data);
    setState(() {
      _messages.removeWhere((element) => element.id == data);
    });
  }

  void _editMessage(data) {
    print(data);
    var index = _messages.indexWhere((element) => element.id == data['_id']);
    var message = _messages.elementAt(index);

    _messages[index] = ChatMessage(
      id: message.id,
      text: data['message'],
      uid: message.uid,
      isMyMessage: false,
      animationController: AnimationController(
          vsync: this, duration: const Duration(milliseconds: 0))
        ..forward(),
    );

    setState(() {});
  }

  Map? messageToEdit;
  int? indexToEdit;

  @override
  Widget build(BuildContext context) {
    final userFor = chatService.userFor;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushReplacementNamed(context, 'users');
            }),
        actions: [],
        title: Column(
          children: [
            CircleAvatar(
              child: Text(
                userFor.name.substring(0, 2),
                style: const TextStyle(fontSize: 12),
              ),
              backgroundColor: Colors.blue[100],
              maxRadius: 14,
            ),
            const SizedBox(
              height: 3,
            ),
            Text(
              userFor.name,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 12,
              ),
            )
          ],
        ),
        centerTitle: true,
        elevation: 1,
      ),
      body: Column(
        children: [
          Flexible(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: _messages.length,
              itemBuilder: (_, i) {
                return GestureDetector(
                  child: _messages[i],
                  onTap: _messages[i].isMyMessage
                      ? () {
                          final RenderBox renderBox =
                              context.findRenderObject() as RenderBox;
                          final offset = renderBox.localToGlobal(Offset.zero);

                          final left = offset.dx + renderBox.size.width - 100;
                          final top = offset.dy + renderBox.size.height + 50;
                          final right = left + renderBox.size.width;

                          showMenu(
                              color: Colors.blue,
                              semanticLabel: _messages[i].text,
                              context: context,
                              position:
                                  RelativeRect.fromLTRB(left, top, right, 0),
                              items: <PopupMenuEntry<dynamic>>[
                                PopupMenuItem(
                                  child: const Text(
                                    'Editar',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                  onTap: () async {
                                    setState(() {
                                      messageToEdit = {
                                        "_id": _messages[i].id,
                                        "from": _messages[i].uid,
                                        "to": userFor.uid,
                                        "message": _messages[i].text,
                                      };

                                      indexToEdit = i;
                                      _editing = true;
                                      _textController.text = _messages[i].text;
                                    });
                                  },
                                ),
                                PopupMenuItem(
                                  child: const Text(
                                    'Eliminar',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                  onTap: () async {
                                    var id = _messages[i].id;
                                    var ok =
                                        await chatService.deleteMessage(id);
                                    if (ok) {
                                      socketService.socket.emit(
                                          'delete-message',
                                          {'id': id, 'to': userFor.uid});
                                      setState(() {
                                        _messages.removeAt(i);
                                      });
                                    }
                                  },
                                ),
                              ]);
                        }
                      : null,
                );
              },
              reverse: true,
            ),
          ),
          const Divider(
            height: 1,
          ),
          Container(
            color: Colors.white,
            child: _inputChat(context),
          )
        ],
      ),
    );
  }

  bool _editing = false;
  Widget _inputChat(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          if (_editing)
            Container(
              color: Colors.blue[300],
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 5),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: Colors.grey,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_messages[indexToEdit!].text),
                    IconButton(
                        onPressed: () {
                          setState(() {
                            _editing = false;
                            indexToEdit = null;
                            messageToEdit = null;
                            _textController.clear();
                          });
                        },
                        icon: Icon(
                          Icons.close,
                          size: 15,
                        ))
                  ],
                ),
              ),
            ),
          Container(
            color: Colors.blue[300],
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white,
              ),
              margin: const EdgeInsets.symmetric(horizontal: 8),
              padding: const EdgeInsets.only(left: 12),
              child: Row(
                children: [
                  Flexible(
                    child: TextField(
                      controller: _textController,
                      onSubmitted: (text) {
                        if (messageToEdit != null) {
                          _editThisMessage(context, text);
                          setState(() {});
                        } else {
                          _handleSubmit(text);
                        }
                      },
                      onChanged: (text) {
                        setState(() {
                          if (text.trim().isNotEmpty) {
                            _isWrite = true;
                          } else {
                            _isWrite = false;
                          }
                        });
                      },
                      decoration: const InputDecoration.collapsed(
                        hintText: 'Enviar mensaje',
                      ),
                      focusNode: _focusNode,
                      minLines: 1,
                      maxLines: 3,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    child: io.Platform.isIOS
                        ? CupertinoButton(
                            child: const Text('Enviar'),
                            onPressed: _isWrite
                                ? () => _handleSubmit(_textController.text)
                                : null,
                          )
                        : Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            child: IconTheme(
                              data: IconThemeData(color: Colors.blue[400]),
                              child: IconButton(
                                highlightColor: Colors.transparent,
                                splashColor: Colors.transparent,
                                onPressed: _isWrite
                                    ? () async {
                                        if (messageToEdit != null) {
                                          _editThisMessage(
                                              context, _textController.text);
                                          setState(() {});
                                        } else {
                                          _handleSubmit(_textController.text);
                                        }
                                      }
                                    : null,
                                icon: const Icon(
                                  Icons.send,
                                ),
                              ),
                            ),
                          ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _editThisMessage(BuildContext context, String text) async {
    _textController.clear();
    _focusNode.requestFocus();
    var newMessage = {
      "_id": messageToEdit!['_id'],
      "from": messageToEdit!['from'],
      "to": messageToEdit!['to'],
      "message": text,
    };
    var ok = await chatService.editMessage(newMessage);

    if (ok) {
      socketService.socket.emit('edit-message', newMessage);

      var message = _messages.elementAt(indexToEdit!);

      _messages[indexToEdit!] = ChatMessage(
        id: message.id,
        text: text,
        uid: message.uid,
        isMyMessage: true,
        animationController: AnimationController(
            vsync: this, duration: const Duration(milliseconds: 0))
          ..forward(),
      );

      setState(() {
        _editing = false;
        indexToEdit = null;
        messageToEdit = null;
      });
    } else {
      setState(() {
        _editing = false;
        indexToEdit = null;
        messageToEdit = null;
      });
    }

    _focusNode.unfocus();
  }

  _handleSubmit(String text) async {
    if (text.isEmpty) return;

    _textController.clear();
    _focusNode.requestFocus();

    var message = {
      'from': authService.user!.uid,
      'to': chatService.userFor.uid,
      'message': text
    };

    final newMessage = await chatService.sendMessage(message);
    if (newMessage != null) {
      final newChatMessage = ChatMessage(
        id: newMessage.id,
        text: newMessage.message,
        uid: authService.user!.uid,
        animationController: AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 200),
        ),
      );

      socketService.emit('personal-message', {
        'uid': newMessage.id,
        'from': authService.user!.uid,
        'to': chatService.userFor.uid,
        'message': text
      });

      _messages.insert(0, newChatMessage);
      newChatMessage.animationController.forward();

      setState(() {
        _isWrite = false;
      });
    }
  }

  // @override
  // void dispose() {
  //   for (ChatMessage message in _messages) {
  //     message.animationController.dispose();
  //   }

  //   socketService.socket.off('personal-message');

  //   super.dispose();
  // }

  // void _loadMessages() {
  //   if (limit <= _messages.length) {
  //     limit *= 2;
  //     _loadHistory(chatService.userFor.uid);
  //   }
  //   setState(() {});
  //   _refreshController.refreshCompleted();
  // }
}
