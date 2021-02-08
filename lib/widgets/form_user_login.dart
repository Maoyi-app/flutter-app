import 'dart:io';

import 'package:flutter/material.dart';
import 'package:***REMOVED***/generated/l10n.dart';
import 'package:***REMOVED***/pages/login/login_formdata.dart';
import 'package:***REMOVED***/utils/services/auth_service.dart';
import 'package:***REMOVED***/utils/services/***REMOVED***_rest_client.dart';
import 'package:***REMOVED***/widgets/formfield_auth.dart';
import 'package:***REMOVED***/config/routes/routes.dart' as routes;
import 'package:***REMOVED***/utils/form/form_validators.dart';

import 'package:strings/strings.dart';

class LoginUserForm extends StatefulWidget {
  LoginUserForm({Key key}) : super(key: key);
  final authService = AuthService(***REMOVED***RestClient());

  @override
  _LoginUserFormState createState() => _LoginUserFormState();
}

class _LoginUserFormState extends State<LoginUserForm> {
  final _formKey = GlobalKey<FormState>();
  LoginUserFormData _loginUserFormData;
  String _errorMessage = "";
  bool _displayAwaitHolder = false;

  @override
  void initState() {
    super.initState();
    _loginUserFormData = LoginUserFormData();
  }

  /// This function ask auth_service to do a login request,
  /// if successful we navigate to the home page. If failure occur,
  /// it is handled and displayed in a friendly manner to the user
  void _handleLoginRequest() async {
    final FormState formState = _formKey.currentState;
    setState(() {
      _errorMessage = "";
      _displayAwaitHolder = true;
    });
    formState.save();
    if (formState.validate()) {
      try {
        await widget.authService.doLoginUser(_loginUserFormData).then((user) {
          if(user != null) {
            // LOGIN OK
            print('FORMLOGIN: OK: "' + user.email + '"');
            Navigator.pushNamed(context, routes.Home);
          } else {
            // JSON ERROR HANDELING
            print("FORMLOGIN: PARSE ERROR");
            setState(() {
              _errorMessage = S.of(context).msgErrorClientSerializationFail;
            });
          }
        });
      } on HttpException catch (e) {
        // SERVER ERROR CODE HANDELING
        setState(() {
          _errorMessage = e.message;
          switch (e.message) {
            case "401":
              _errorMessage = S.of(context).msgErrorLoginRejected;
              break;
            default:
              _errorMessage = S.of(context).msgErrorServerFail;
              break;
          }
        });
      } on IOException {
        // SOCKET/IO TRANSPORT ERROR HANDELING
        setState(() {
          _errorMessage = S.of(context).msgErrorNetworkFail;
        });
      }

      /// Disable wait holder on response
      setState(() {
        _displayAwaitHolder = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FormFieldAuth(
              title: capitalize(S.of(context).email),
              hint: S.of(context).emailHint,
              keyboardType: TextInputType.emailAddress,
              onSaved: (newValue) => {_loginUserFormData.email = newValue},
              validator: (value) {
                return validateEmail(value, context);
              },
            ),
            FormFieldAuth(
              title: capitalize(S.of(context).password),
              hint: capitalize(S.of(context).passwordHint),
              isObscured: true,
              keyboardType: TextInputType.emailAddress,
              onSaved: (newValue) {
                _loginUserFormData.password = newValue;
              },
              validator: (value) {
                return validateNotEmptyInput(value, context);
              },
            ),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  /// LOADING PLACEHOLDER TODO: IN future add loading anim
                  Visibility(
                    child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          S.of(context).msgAwaitResponse,
                          style: Theme.of(context).primaryTextTheme.headline4.copyWith(
                            color: Colors.white,
                          )
                        )),
                    visible: _displayAwaitHolder,
                  ),

                  /// ERROR MESSAGE
                    Text(
                      _errorMessage,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).primaryTextTheme.headline5.copyWith(
                        color: Colors.amberAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                  /// BUTTONS
                  Column(mainAxisSize: MainAxisSize.min, children: [
                    FlatButton(
                      child: Text(
                        S.of(context).loginUser,
                        style: Theme.of(context).primaryTextTheme.headline1.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      onPressed: () {
                        /// Validate form, if OK send await
                        if (_formKey.currentState.validate()) {
                          _handleLoginRequest();
                        }
                      },
                    ),
                    SizedBox(height: 24.0),
                    FlatButton(
                      child: Text(
                        S.of(context).createUser,
                        style: Theme.of(context).primaryTextTheme.headline3.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      onPressed: () {
                        Navigator.pushNamed(context, routes.UserNew);
                      },
                    ),
                  ]),
                ],
              ),
            ),
          ],
        )
    );
  }
}
