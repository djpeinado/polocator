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
import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

import '../interfaces.dart';
import '../misc/const.dart';

class Device implements IDevice {
  Device._();
  static final Device instance = Device._();

  String getTimeBasedUuid() {
    var uuid = Uuid();
    // Generate a v1 (time-based) id
    return uuid.v1();
  }

  @override
  Future<String> getDeviceId() async {
    if (!kIsWeb) {
      try {
        DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
        if (Platform.isAndroid) {
          AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
          return androidInfo.androidId; //UUID for Android
        } else if (Platform.isIOS) {
          IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
          return iosInfo.identifierForVendor; //UUID for iOS
        }
      } on PlatformException {}
    }
    return getTimeBasedUuid();
  }
}
