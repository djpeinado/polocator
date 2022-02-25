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
import 'dart:collection';

import 'package:flutter/material.dart';

import '../controller/controller.dart';
import '../i18n/i18n.dart';
import '../misc/const.dart';
import '../misc/utils.dart';
import '../model/model.dart';
import '../ui/theme.dart';
import 'page_add_connection.dart';
import 'widgets/material_card.dart';

class HomePage extends StatefulWidget {
  static const routeName = RouteName.pageHome;
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  HashMap<String, ConnectionStatus?>? _connections;
  bool _isInitialized = false;

  void _navigateToAddConnection(BuildContext context) {
    Navigator.pushNamed(
      context,
      AddConnectionPage.routeName,
    );
  }

  void _signOut(BuildContext context) async {
    await Controller.signOut();
    Utils.navigateTo(context, RouteName.pageLogin, removeUntil: true);
  }

  void _switchThemeMode() {
    AppThemeMode.switchThemeMode();
    setState(() {});
  }

  void _locate(String email) {
    Utils.navigateTo(context, RouteName.pageLocate, param: email);
  }

  void _allow(BuildContext context, String email) {
    Model.allowConnection(context, email).then((bool success) {
      if (success) {
        _load();
      }
    });
  }

  void _block(BuildContext context, String email) {
    Model.blockConnection(context, email).then((bool success) {
      if (success) {
        _load();
      }
    });
  }

  List<Widget> _list(BuildContext context) {
    List<Widget> list = [];
    if (_connections != null) {
      _connections!.forEach((email, connectionsStatus) {
        String? actionButtonText1;
        String? actionButtonText2;
        void Function()? onActionButtonPressed1;
        void Function()? onActionButtonPressed2;
        switch (connectionsStatus) {
          case ConnectionStatus.ALLOWED:
            actionButtonText1 = I18N.getString(I18N.keyLocateButton);
            actionButtonText2 = I18N.getString(I18N.keyBlockButton);
            onActionButtonPressed1 = () {
              _locate(email);
            };
            onActionButtonPressed2 = () {
              _block(context, email);
            };
            break;
          case ConnectionStatus.PENDING:
            actionButtonText1 = I18N.getString(I18N.keyAllowButton);
            actionButtonText2 = I18N.getString(I18N.keyBlockButton);
            onActionButtonPressed1 = () {
              _allow(context, email);
            };
            onActionButtonPressed2 = () {
              _block(context, email);
            };
            break;
          case ConnectionStatus.BLOCKED:
            actionButtonText1 = I18N.getString(I18N.keyAllowButton);
            onActionButtonPressed1 = () {
              _allow(context, email);
            };
            break;
          default:
        }
        Widget item = MaterialCard(
            title: email,
            secondaryText: Utils.enumToString(connectionsStatus),
            actionButtonText1: actionButtonText1,
            actionButtonText2: actionButtonText2,
            onActionButtonPressed1: onActionButtonPressed1,
            onActionButtonPressed2: onActionButtonPressed2);
        list.add(item);
      });
    }
    return list;
  }

  void _load() {
    Model.getConnections().then((connections) {
      setState(() => _connections = connections);
    });
  }

  void _loadFirstTime() {
    if (!_isInitialized) {
      _load();
      _isInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    Controller.navigateToLoginIfNotLoggedIn(context);
    _loadFirstTime();
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(I18N.getString(I18N.keyHomeTitle)),
        actions: [
          IconButton(
            tooltip: I18N.getString(I18N.keyRefreshButton),
            icon: const Icon(
              Icons.refresh,
            ),
            onPressed: () {
              _load();
            },
          ),
          IconButton(
            tooltip: I18N.getString(AppThemeMode.isDarkMode!
                ? I18N.keyThemeModeSwitchLightButton
                : I18N.keyThemeModeSwitchDarkButton),
            icon: Icon(
              AppThemeMode.isDarkMode! ? Icons.brightness_high : Icons.bedtime,
            ),
            onPressed: () {
              _switchThemeMode();
            },
          ),
          IconButton(
            tooltip: I18N.getString(I18N.keyLogoutButton),
            icon: const Icon(
              Icons.exit_to_app_rounded,
            ),
            onPressed: () {
              _signOut(context);
            },
          )
        ],
      ),
      body: ListView(
        children: _list(context),
      ),
      floatingActionButton: new FloatingActionButton(
          child: new Icon(Icons.add_circle),
          tooltip: I18N.getString(I18N.keyAddConnectionButton),
          onPressed: () {
            _navigateToAddConnection(context);
          }),
    );
  }
}
