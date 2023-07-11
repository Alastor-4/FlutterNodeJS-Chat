import 'package:flutter/material.dart';

class LoginButton extends StatelessWidget {
  final String text;
  final void Function()? onPressed;

  const LoginButton({
    Key? key,
    required this.text,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
        elevation: MaterialStateProperty.all(2),
        backgroundColor: MaterialStateProperty.all(Colors.blue),
        shape: MaterialStateProperty.all(const StadiumBorder()),
      ),
      onPressed: onPressed,
      child: SizedBox(
        width: double.infinity,
        height: 55,
        child: Center(
          child: Text(
            text,
            style: const TextStyle(fontSize: 17),
          ),
        ),
      ),
    );
  }
}
