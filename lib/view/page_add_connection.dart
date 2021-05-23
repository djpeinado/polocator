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
import 'package:flutter/material.dart';

import '../controller/controller.dart';
import '../i18n/i18n.dart';
import '../misc/const.dart';
import '../misc/utils.dart';
import '../model/model.dart';

class AddConnectionPage extends StatefulWidget {
  static const routeName = RouteName.pageAdd;

  @override
  _AddConnectionPageState createState() => _AddConnectionPageState();
}

class _AddConnectionPageState extends State<AddConnectionPage> {
  late bool _isButtonEnabled;
  late bool _isLoading;
  String _email = "";

  @override
  void initState() {
    super.initState();
    _isButtonEnabled = false;
    _isLoading = false;
    //Model.getContacts();
  }

  void processButtonEnabled() {
    setState(() {
      _isButtonEnabled =
          !_isLoading && _email.isNotEmpty && Utils.isValidEmail(_email);
    });
  }

  void _add(context) async {
    _isLoading = true;
    processButtonEnabled();
    if (await Model.addConnection(context, _email)) {
      Utils.navigateTo(context, RouteName.pageHome);
    } else {
      _isLoading = false;
      processButtonEnabled();
    }
  }

  @override
  Widget build(BuildContext context) {
    Controller.navigateToLoginIfNotLoggedIn(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(I18N.getString(I18N.keyAddConnectionTitle)),
      ),
      body: Container(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                child: TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Google ID (email)',
                  ),
                  onChanged: (value) {
                    _email = value;
                    processButtonEnabled();
                  },
                ),
                width: MediaQuery.of(context).size.width * 0.5,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isButtonEnabled
                    ? () {
                        _add(context);
                      }
                    : null,
                child: Icon(
                  Icons.add,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
