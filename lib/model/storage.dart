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
import '../E2EE/e2ee.dart' as e2ee;
import '../factory.dart';
import 'data.dart';
import 'model.dart';

class Storage {
  Storage._();
  static final Storage instance = Storage._();
  String? _userIdCurrent;

  Future<bool> storeUser(User user) async {
    if (user.id != null) {
      _userIdCurrent = user.id;
      if (!await implStorageCloud.existsUser(user.id)) {
        if (!await implStorageCloud.addUser(
            user, implStorageSecure.createSecureKey())) {
          return false;
        }
      } else {
        Map<String, dynamic> userData = {
          User.keyDeviceId: user.deviceId,
          User.keyPushNotificationId: user.pushNotificationsId,
        };
        if (!await implStorageCloud.updateUser(user.id, userData)) {
          return false;
        }
      }
      // Create encryption keys and store private in secure storage
      final pair = await e2ee.X25519().generateKeyPair();
      // Set user encription keys
      await implStorageLocal.write(
          User.keyEncryptionKeyPublic, pair.publicKey.toBase64());
      List<int>? keySecure = await implStorageCloud.getUserKeySecure(user.id!);
      await implStorageSecure.init(keySecure);
      await implStorageSecure.write(
          User.keyEncryptionKeyPrivate, pair.secretKey.toBase64());
      return true;
    }
    return false;
  }

  void updateUserPushNotificationsId(String value) {
    if (_userIdCurrent != null) {
      implStorageCloud
          .updateUser(_userIdCurrent, {User.keyPushNotificationId: value});
    }
  }

  String? getDeviceId() {
    return implStorageLocal.get(User.keyDeviceId);
  }

  Future<void> setDeviceId(String deviceId) async {
    await implStorageLocal.write(User.keyDeviceId, deviceId);
  }

  String? getEncryptionKeyPublic() {
    return implStorageLocal.get(User.keyEncryptionKeyPublic);
  }
}
