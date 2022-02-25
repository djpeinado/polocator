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

import 'package:firebase_messaging/firebase_messaging.dart';

import 'model/data.dart';

abstract class IAuth {
  Future<User?> signIn({bool silent = false});
  Future<void> signOut();
  bool isLoggedIn();
  String? getCurrentUserId();
}

abstract class IStorageCloud {
  Future<bool> addUser(User user, List<int> keySecure);
  Future<bool> updateUser(String userId, Map<String, dynamic> data);
  Future<bool> existsUser(String userId);
  Future<List<int>?> getUserKeySecure(String userId);
  Future<String?> getUserDeviceId(String userId);
  Future<bool> setConnection(
      String userId, String email, ConnectionStatus status);
  Future<HashMap<String, ConnectionStatus?>> getConnections(String userId);
}

abstract class IStorageSecure {
  Future<void>? init(List<int> keySecure);
  Future<void> write(String key, String value);
  Future<String?>? get(String key);
  List<int> createSecureKey();
  Future<void> clear();
}

abstract class IStorageLocal {
  Future<void> init();
  Future<void> write(String key, dynamic value);
  dynamic get(String key, {dynamic defaultValue});
  Future<void> clear();
}

abstract class IPushNotifications {
  Future<String?> getId();
  void setRefreshIdHandler(Function(String) f);
  void setMessageHandler(Future<void> Function(RemoteMessage) f);
}

abstract class IAppService {
  Future<Contacts?> getContacts();
  Future<bool> requestLocation(
      String emailTarget, String email, String encryptionKeyPublic);
  Future<bool> sendLocation(String email, String keyPublic, String keyPrivate);
}

abstract class IDevice {
  Future<String> getDeviceId();
}
