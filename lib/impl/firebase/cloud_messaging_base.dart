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
import 'package:firebase_messaging/firebase_messaging.dart';

import '../../interfaces.dart';
import '../../misc/exceptions.dart';

class FirebaseCloudMessagingBase implements IPushNotifications {
  @override
  Future<String?> getId() async {
    // Ask for permission
    NotificationSettings settings =
        await FirebaseMessaging.instance.requestPermission();
    switch (settings.authorizationStatus) {
      case AuthorizationStatus.denied:
      case AuthorizationStatus.notDetermined:
        throw new NotificationsNotGrantedException();
      default:
    }
    return FirebaseMessaging.instance.getToken();
  }

  @override
  void setRefreshIdHandler(Function(String) f) {
    FirebaseMessaging.instance.onTokenRefresh.listen((token) {
      f(token);
    });
  }

  @override
  void setMessageHandler(Future<void> Function(RemoteMessage) f) {
    FirebaseMessaging.onMessage.listen(f);
    FirebaseMessaging.onMessageOpenedApp.listen(f);
    FirebaseMessaging.onBackgroundMessage(f);
  }
}
