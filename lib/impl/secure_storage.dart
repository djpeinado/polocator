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
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../interfaces.dart';

class DeviceSecureStorage implements IStorageSecure {
  late FlutterSecureStorage _storage;

  DeviceSecureStorage._() {
    _storage = new FlutterSecureStorage();
  }

  static final DeviceSecureStorage instance = DeviceSecureStorage._();

  @override
  Future<void> write(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  @override
  Future<String?> get(String key) async {
    return await _storage.read(key: key);
  }

  @override
  List<int> createSecureKey() {
    // Not needed
    return List.empty();
  }

  @override
  Future<void>? init(List<int>? keySecure) {
    // Not needed
    return null;
  }

  @override
  Future<void> clear() async {
    await _storage.deleteAll();
  }
}
