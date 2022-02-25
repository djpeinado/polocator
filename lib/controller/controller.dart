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
import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:location/location.dart' as loc;

import '../factory.dart';
import '../i18n/i18n.dart';
import '../misc/const.dart';
import '../misc/utils.dart';
import '../model/model.dart';
import 'auth.dart';
import 'location.dart';

class Controller {
  // ignore: close_sinks
  static StreamController<LocationResponse>? _onLocateStreamController;

  Controller._();
  static final Controller instance = Controller._();

  static void setLocateStreamController(
      StreamController<LocationResponse>? onLocateStreamController) {
    _onLocateStreamController = onLocateStreamController;
  }

  static Future<void> handlePushNotification(RemoteMessage message) async {
    print("########## handlePushNotification: message=${message.data}");
    if (message.data.isNotEmpty &&
        message.data.containsKey(Functions.keyOperation)) {
      String? keyPrivate =
          await implStorageSecure.get(User.keyEncryptionKeyPrivate);
      print("########## handlePushNotification: keyPrivate=$keyPrivate");
      if (keyPrivate != null) {
        switch (message.data[Functions.keyOperation]) {
          case Functions.opSendLocation:
            if (message.data.containsKey(User.keyEmail) &&
                message.data.containsKey(User.keyEncryptionKeyPublic)) {
              implAppService.sendLocation(message.data[User.keyEmail],
                  message.data[User.keyEncryptionKeyPublic], keyPrivate);
            }
            break;
          case Functions.opResponseLocation:
            if (message.data.containsKey(User.keyEmail) &&
                message.data.containsKey(User.keyEncryptionKeyPublic) &&
                message.data.containsKey(Functions.keyData)) {
              String email = message.data[User.keyEmail];
              String keyPublic = message.data[User.keyEncryptionKeyPublic];
              String data = message.data[Functions.keyData];
              String? keyPublicCurrent = Model.getKeyPublic();
              print(
                  "########## responseLocation: keyPublicCurrent=$keyPublicCurrent");
              print(
                  "########## responseLocation($email): keyPrivate=$keyPrivate");
              print(
                  "########## responseLocation($email): keyPublic=$keyPublic");

              print("########## responseLocation($email): data=$data");
              String locationString =
                  await Utils.decryptWithCRC(keyPrivate, keyPublic, data);
              print(
                  "########## responseLocation($email): locationString=$locationString");
              loc.LocationData location = Location.deserialize(locationString);
              double? lat = location.latitude;
              double? lon = location.longitude;
              print("########## responseLocation($email): lat=$lat lon=$lon");
              if (lat != null && lon != null) {
                LocationResponse locationResponse = LocationResponse();
                locationResponse.email = email;
                locationResponse.location = location;
                if (_onLocateStreamController != null &&
                    !_onLocateStreamController!.isClosed &&
                    !_onLocateStreamController!.isPaused &&
                    _onLocateStreamController!.hasListener) {
                  _onLocateStreamController!.add(locationResponse);
                }
              }
            }
            break;
        }
      }
    }
  }

  static void init() {
    implPushNotifications.setMessageHandler(Controller.handlePushNotification);
  }

  static Future<bool> isLoggedIn() async {
    return Auth.instance.isLoggedIn() && await Model.isDeviceIdCurrentUser();
  }

  static void navigateToLoginIfNotLoggedIn(context) async {
    if (!await isLoggedIn()) {
      Utils.navigateTo(context, RouteName.pageLogin, removeUntil: true);
    }
  }

  static signOut() async {
    await Auth.instance.signOut();
    await implStorageLocal.clear();
    await implStorageSecure.clear();
  }

  static Future<ReturnStatus> signIn(BuildContext context,
      {bool silent = false}) async {
    ReturnStatus status = ReturnStatus.ERROR;
    User? user = await Auth.instance.signIn(silent: silent);
    if (user != null) {
      status = await Model.storeUser(user);
      if (status == ReturnStatus.OK) {
        implPushNotifications
            .setRefreshIdHandler(Model.updateUserPushNotificationsId);
        Utils.toast(context, I18N.getString(I18N.keyLoginSuccess),
            hideCurrent: true);
        return ReturnStatus.OK;
      }
    }
    Utils.toast(context, I18N.getString(I18N.keyLoginFailed),
        hideCurrent: true);
    await signOut();
    return status;
  }

  static bool isSignInSilentlyDone() {
    return Auth.instance.isSignInSilentlyDone;
  }

  static Future<loc.LocationData?> getLocation() {
    return Location.instance.getLocation();
  }

  static loc.LocationData? getLastLocation() {
    return Location.instance.getLastLocation();
  }

  static Future<bool> requestLocation(String emailTarget) async {
    String? email = await Model.getEmail();
    String? keyPublic = Model.getKeyPublic();
    if (email != null && keyPublic != null) {
      return await implAppService.requestLocation(
          emailTarget, email, keyPublic);
    } else {
      print(
          "requestLocation: cannot request location: email or keyPublic null");
      return false;
    }
  }
}
