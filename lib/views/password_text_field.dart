import 'package:bloc_testing/strings.dart' show enterYourPasswordHere;
import 'package:flutter/material.dart';

class PasswordTextField extends StatelessWidget {
  final TextEditingController passwordTextField;

  const PasswordTextField({
    Key? key,
    required this.passwordTextField,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: passwordTextField,
      obscureText: true,
      decoration: const InputDecoration(
        hintText: enterYourPasswordHere,
      ),
    );
  }
}
