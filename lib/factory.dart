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
import 'impl/device.dart';
import 'impl/firebase/authentication.dart';
import 'impl/firebase/cloud_firestore.dart';
import 'impl/firebase/cloud_messaging.dart'
    if (dart.library.js) 'impl/firebase/cloud_messaging_web.dart';
import 'impl/firebase/functions.dart';
import 'impl/hive.dart';
import 'impl/secure_storage.dart';
import 'misc/const.dart';

final implAuth = FirebaseAuthentication.instance;
final implPushNotifications = FirebaseCloudMessaging.instance;
final implStorageCloud = FirebaseCloudStore.instance;
final implStorageLocal = HiveStorageLocal.instance;
final implStorageSecure =
    kIsWeb ? HiveStorageSecure.instance : DeviceSecureStorage.instance;
final implAppService = FirebaseFunctions.instance;
final implDevice = Device.instance;
