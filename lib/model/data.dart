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
import 'package:location/location.dart' as loc;

class User {
  static const keyCollection = 'users';
  static const keyId = 'id';
  static const keyUid = 'uid';
  static const keyEncryptionKeyPrivate = 'keyPrivate';
  static const keyEncryptionKeyPublic = 'keyPublic';
  static const keyName = 'name';
  static const keyEmail = 'email';
  static const keyPushNotificationId = 'pushNotificationId';
  static const keyDeviceId = 'deviceId';
  static const keyKeySecure = 'keySecure';
  static const keyEmailTarget = 'emailTarget';

  String? id;
  String? uid;
  String? pushNotificationsId;
  String? email;
  String? name;
  String? deviceId;
}

class Connection {
  static const keyCollection = 'connections';
  static const keyStatus = 'status';
}

enum ConnectionStatus { ALLOWED, PENDING, BLOCKED }

class Contact {
  String? email;
  String? name;
}

class Contacts {
  late List<Contact> app;
  late List<Contact> all;
}

enum ReturnStatus { OK, ERROR, NOTIF_NOT_GRANTED }

class LocationResponse {
  late String email;
  late loc.LocationData location;
}
