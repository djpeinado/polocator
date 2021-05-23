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
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../interfaces.dart';

class _HiveStorage {
  static bool _isInitialized = false;
  static Future<void> init() async {
    if (!_isInitialized) {
      await Hive.initFlutter();
      _isInitialized = true;
    }
  }
}

class HiveStorageLocal implements IStorageLocal {
  static const keyBox = 'storage_local';

  HiveStorageLocal._();
  static final HiveStorageLocal instance = HiveStorageLocal._();

  Box? _box;

  @override
  Future<void> init() async {
    await _HiveStorage.init();
    if (_box == null) {
      _box = await Hive.openBox(keyBox);
    }
  }

  @override
  Future<void> write(String key, dynamic value) async {
    await init();
    await _box!.put(key, value);
  }

  @override
  dynamic get(String key, {dynamic defaultValue}) {
    if (_box != null && _box!.isOpen && _box!.containsKey(key)) {
      return _box!.get(key, defaultValue: defaultValue);
    }
    return defaultValue;
  }

  @override
  Future<void> clear() async {
    if (_box != null) {
      await _box!.clear();
    }
  }
}

class HiveStorageSecure implements IStorageSecure {
  static const keyBoxSecureStorage = 'storage_secure';

  HiveStorageSecure._();
  static final HiveStorageSecure instance = HiveStorageSecure._();

  Box? _box;

  @override
  List<int> createSecureKey() {
    return Hive.generateSecureKey();
  }

  Future<void> init(List<int>? keySecure) async {
    _HiveStorage.init();
    try {
      _box = await Hive.openBox(keyBoxSecureStorage,
          encryptionCipher: HiveAesCipher(keySecure!));
    } catch (e, stacktrace) {
      print(stacktrace);
    }
  }

  @override
  Future<void> write(String key, String value) async {
    if (_box != null) {
      await _box!.put(key, value);
    }
  }

  @override
  Future<String>? get(String key) {
    if (_box != null) {
      return _box!.get(key);
    }
    return null;
  }

  @override
  Future<void> clear() async {
    if (_box != null) {
      await _box!.clear();
      await _box!.close();
      await _box!.deleteFromDisk();
      _box = null;
    }
  }
}
