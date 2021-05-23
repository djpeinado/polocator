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
// ignore: import_of_legacy_library_into_null_safe
import 'package:flutter_translate/flutter_translate.dart';

class Locale {
  static const fallback = 'es';
  static const supported = ['en', 'es'];
}

class I18N {
  static const keyAppTitle = 'app.main.title';
  static const keyLoginButton = 'app.login.button';
  static const keyLoginFailed = 'app.login.failed';
  static const keyLoginSuccess = 'app.login.success';
  static const keyLoginAllowNotif = 'app.login.allowNotif';
  static const keyLoginNotifNotGranted = 'app.login.notifNotGranted';
  static const keyLogoutButton = 'app.home.logout';
  static const keyRefreshButton = 'app.home.refresh';
  static const keyAllowButton = 'app.home.allow';
  static const keyBlockButton = 'app.home.block';
  static const keyLocateButton = 'app.home.locate';
  static const keyAddConnectionButton = 'app.home.addConnection';
  static const keyHomeTitle = 'app.home.title';
  static const keyAddConnectionTitle = 'app.addConnection.title';
  static const keyAddConnectionFailed = 'app.addConnection.failed';
  static const keyThemeModeSwitchLightButton = 'app.home.themeModeSwitchLight';
  static const keyThemeModeSwitchDarkButton = 'app.home.themeModeSwitchDark';
  static const keyLocateTitle = "app.locate.title";

  static String getString(String key) {
    return translate(key);
  }
}
