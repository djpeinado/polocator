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
import 'package:flutter_localizations/flutter_localizations.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:flutter_translate/flutter_translate.dart';

import 'controller/controller.dart';
import 'i18n/i18n.dart';
import 'impl/firebase/core.dart';
import 'misc/const.dart';
import 'model/model.dart';
import 'ui/style.dart';
import 'ui/theme.dart';
import 'view/page_add_connection.dart';
import 'view/page_home.dart';
import 'view/page_login.dart';
import 'view/page_locate.dart';
//import 'view/page_test.dart';

void main() async {
  var delegate = await LocalizationDelegate.create(
      fallbackLocale: Locale.fallback, supportedLocales: Locale.supported);
  await Model.init();
  FirebaseCore.instance.init();
  runApp(LocalizedApp(delegate, App()));
}

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    super.initState();
    AppThemeMode.instance.addListener(() {
      setState(() {});
    });
    Controller.init();
  }

  @override
  Widget build(BuildContext context) {
    var localizationDelegate = LocalizedApp.of(context).delegate;

    return LocalizationProvider(
      state: LocalizationProvider.of(context).state,
      child: MaterialApp(
        title: AppKeys.title,
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          localizationDelegate
        ],
        supportedLocales: localizationDelegate.supportedLocales,
        locale: localizationDelegate.currentLocale,
        theme: Style.appThemeLight,
        darkTheme: Style.appThemeDark,
        themeMode: AppThemeMode.getCurrentThemeMode(),
        initialRoute: LoginPage.routeName,
        //initialRoute: TestPage.routeName,
        routes: {
          //TestPage.routeName: (context) => TestPage(),
          HomePage.routeName: (context) => HomePage(),
          LoginPage.routeName: (context) => LoginPage(),
          LocatePage.routeName: (context) => LocatePage(),
          AddConnectionPage.routeName: (context) => AddConnectionPage(),
        },
      ),
    );
  }
}
