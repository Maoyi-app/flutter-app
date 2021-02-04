import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:maoyi/utils/form/login_user_form.dart';
import 'package:maoyi/widgets/logo.dart';
import 'package:maoyi/widgets/stack_blurredbackground.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: BlurredBackgroundWidget(
        backgroundImage: AssetImage('assets/images/background-oceanview.jpg'),
        container: Container(
          padding: EdgeInsets.only(
            /// https://stackoverflow.com/a/65624909
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SafeArea(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              children: <Widget>[
                SizedBox(
                  height: 52.0,
                ), // Spacing between top and header
                Align(alignment: Alignment.center, child: Logo()),
                LoginUserForm(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
