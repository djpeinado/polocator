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

import 'package:flutter/widgets.dart';

import '../factory.dart';
import '../i18n/i18n.dart';
import '../misc/exceptions.dart';
import '../misc/utils.dart';
import 'data.dart';
import 'storage.dart';

export 'data.dart';

class Model {
  Model._();
  static final Model instance = Model._();

  Contacts? _contacts;
  String? _userIdModel;

  Future<Contacts?> _getContacts({bool force = false}) async {
    if (!implAuth.isLoggedIn()) return null;
    if (force ||
        _contacts == null ||
        implAuth.getCurrentUserId() != _userIdModel) {
      _contacts = await implAppService.getContacts();
      _userIdModel = implAuth.getCurrentUserId();
    }
    return _contacts;
  }

  static Future<Contacts?> getContacts({bool force = false}) async {
    return instance._getContacts(force: force);
  }

  static Future<ReturnStatus> storeUser(User user) async {
    // Set user push notification id
    try {
      user.pushNotificationsId = await implPushNotifications.getId();
      // ignore: unused_catch_clause
    } on NotificationsNotGrantedException catch (e) {
      return ReturnStatus.NOTIF_NOT_GRANTED;
    }

    if (user.pushNotificationsId == null) {
      return ReturnStatus.ERROR;
    }
    // Set device id
    user.deviceId = await getDeviceId();
    var returnStatus = await Storage.instance.storeUser(user)
        ? ReturnStatus.OK
        : ReturnStatus.ERROR;
    return returnStatus;
  }

  static void updateUserPushNotificationsId(String value) {
    Storage.instance.updateUserPushNotificationsId(value);
  }

  static Future<String> getDeviceId() async {
    String? deviceId = Storage.instance.getDeviceId();
    if (deviceId == null) {
      deviceId = await implDevice.getDeviceId();
      Storage.instance.setDeviceId(deviceId);
    }
    return deviceId;
  }

  static Future<String?> getDeviceIdCurrentUser() async {
    String? userId = implAuth.getCurrentUserId();
    return userId != null
        ? await implStorageCloud.getUserDeviceId(userId)
        : null;
  }

  static Future<bool> isDeviceIdCurrentUser() async {
    String deviceId = await getDeviceId();
    String? deviceIdCurrentUser = await getDeviceIdCurrentUser();
    return deviceIdCurrentUser != null && deviceId == deviceIdCurrentUser;
  }

  Future<bool> _setConnection(
      BuildContext context, String email, ConnectionStatus status) async {
    String? userId = implAuth.getCurrentUserId();
    if (userId == null) return false;
    bool success = await implStorageCloud.setConnection(userId, email, status);
    return success;
  }

  Future<bool> _addConnection(BuildContext context, String email) async {
    bool success =
        await _setConnection(context, email, ConnectionStatus.ALLOWED);
    if (!success) {
      Utils.toast(context, I18N.getString(I18N.keyAddConnectionFailed));
    }
    return success;
  }

  Future<bool> _allowConnection(BuildContext context, String email) async {
    bool success =
        await _setConnection(context, email, ConnectionStatus.ALLOWED);
    if (!success) {
      // TODO I18N.keyAllowConnectionFailed
      //Utils.toast(context, I18N.getString(I18N.keyAllowConnectionFailed));
      Utils.toast(context, "TODO ERROR");
    }
    return success;
  }

  Future<bool> _blockConnection(BuildContext context, String email) async {
    bool success =
        await _setConnection(context, email, ConnectionStatus.BLOCKED);
    if (!success) {
      // TODO I18N.keyAllowConnectionFailed
      //Utils.toast(context, I18N.getString(I18N.keyBlockConnectionFailed));
      Utils.toast(context, "TODO ERROR");
    }
    return success;
  }

  static Future<bool> addConnection(BuildContext context, String email) async {
    return instance._addConnection(context, email);
  }

  static Future<HashMap<String, ConnectionStatus?>?> getConnections() async {
    String? userId = implAuth.getCurrentUserId();
    if (userId == null) return null;
    HashMap<String, ConnectionStatus?> connections =
        await implStorageCloud.getConnections(userId);
    return connections;
  }

  static Future<bool> allowConnection(
      BuildContext context, String email) async {
    return instance._allowConnection(context, email);
  }

  static Future<bool> blockConnection(
      BuildContext context, String email) async {
    return instance._blockConnection(context, email);
  }

  static Future<void> init() async {
    await implStorageLocal.init();
  }

  static bool isTherePreviousUser() {
    return Storage.instance.getEncryptionKeyPublic() != null;
  }
}
