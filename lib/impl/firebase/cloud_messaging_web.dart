// ignore: avoid_web_libraries_in_flutter
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
import 'dart:js' as js;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase/firebase.dart' as firebase;

import '../../interfaces.dart';
import '../../misc/const.dart';
import '../../misc/exceptions.dart';

class FirebaseCloudMessaging implements IPushNotifications {
  static final FirebaseCloudMessaging instance = FirebaseCloudMessaging();

  FirebaseMessaging messaging = FirebaseMessaging.instance;

  @override
  Future<String?> getId() async {
    // Ask for permission
    NotificationSettings settings = await messaging.requestPermission();
    switch (settings.authorizationStatus) {
      case AuthorizationStatus.denied:
      case AuthorizationStatus.notDetermined:
        throw new NotificationsNotGrantedException();
      default:
    }

    if (kIsWeb) {
      try {
        String? token = await messaging.getToken(
          vapidKey: js.context[JS.firebaseConfigProxy][JS.vApIdKey],
        );
        return token;
      } on firebase.FirebaseError catch (e) {
        print('FirebaseCloudMessaging - Error: ' + e.toString());
        print('FirebaseException code: ' + e.code);
        if (e.code == 'messaging/permission-blocked') {
          throw new NotificationsNotGrantedException();
        }
        return null;
      } catch (error) {
        print('FirebaseCloudMessaging - Error: ' + error.toString());
        return null;
      }
    }
    return null;
  }

  @override
  void setRefreshIdHandler(Function(String) f) {
    messaging.onTokenRefresh.listen((token) {
      f(token);
    });
  }

  @override
  void setMessageHandler(Function f) {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      f(message);
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      f(message);
    });
    FirebaseMessaging.onBackgroundMessage((RemoteMessage message) {
      return f(message);
    });
  }
}
