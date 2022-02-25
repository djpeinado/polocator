/// Copyright (C) 2021 Alberto Peinado Checa
///
/// This file is part of polocator.
///
/// polocator is free software: you can redistribute it and/or modify
/// it under the terms of the GNU General Public License as published by
/// the Free Software Foundation, either version 3 of the License, or
/// (at your option) any later version.
///
/// polocator is distributed in the hope that it will be useful,
/// but WITHOUT ANY WARRANTY; without even the implied warranty of
/// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
/// GNU General Public License for more details.
///
/// You should have received a copy of the GNU General Public License
/// along with polocator.  If not, see <http://www.gnu.org/licenses/>.
import 'dart:ui';

import 'package:flutter/material.dart';

import '../controller/controller.dart';
import '../i18n/i18n.dart';
import '../misc/const.dart';
import '../misc/utils.dart';
import '../model/data.dart';
import '../model/model.dart';
import '../ui/theme.dart';
import 'page_home.dart';
import 'widgets/flutter_auth_buttons/google.dart';

class LoginPage extends StatefulWidget {
  static const routeName = RouteName.pageLogin;
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = true;
  String _messageInfo = kIsWeb ? I18N.getString(I18N.keyLoginAllowNotif) : "";

  void _navigateToHome(BuildContext context) {
    Utils.navigateTo(context, HomePage.routeName, removeUntil: true);
  }

  void _setLoading(bool value) {
    if (mounted) {
      setState(() {
        _isLoading = value;
      });
    } else {
      _isLoading = value;
    }
  }

  Future<void> _signIn(BuildContext context, {bool silent = false}) async {
    if (!_isLoading) {
      _setLoading(true);
      if (_messageInfo.isNotEmpty) {
        Utils.snack(context, _messageInfo);
      }
    }

    if (await Controller.getLocation() == null) {
      // TODO message error no location
      Utils.toast(context, "FIXME NO LOCATION", hideCurrent: true);
      _setLoading(false);
    } else {
      ReturnStatus status = await Controller.signIn(context, silent: silent);
      if (status == ReturnStatus.OK) {
        _navigateToHome(context);
      } else {
        String messageError = "";
        if (status == ReturnStatus.NOTIF_NOT_GRANTED) {
          messageError = I18N.getString(I18N.keyLoginNotifNotGranted);
        }
        _setLoading(false);
        if (messageError.isNotEmpty) {
          Utils.toast(context, messageError, hideCurrent: true);
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    if (!Controller.isSignInSilentlyDone() && Model.isTherePreviousUser()) {
      Future.delayed(Duration.zero, () {
        _signIn(context, silent: true);
      });
    } else {
      _setLoading(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Text(
                I18N.getString(I18N.keyAppTitle),
                style: new TextStyle(
                  color: AppThemeMode.isDarkMode!
                      ? null
                      : Theme.of(context).colorScheme.primary,
                  fontSize: 36.0,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: 20),
              new Icon(Icons.person_pin_circle,
                  color: AppThemeMode.isDarkMode!
                      ? null
                      : Theme.of(context).colorScheme.primary,
                  size: 150),
              SizedBox(height: 20),
              _isLoading
                  ? CircularProgressIndicator()
                  : GoogleSignInButton(
                      onPressed: () {
                        _signIn(context);
                      },
                      darkMode: true,
                      text: I18N.getString(I18N.keyLoginButton),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
