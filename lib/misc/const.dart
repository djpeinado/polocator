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
import 'package:flutter/foundation.dart' as Foundation;

const bool kIsWeb = Foundation.kIsWeb;
const bool kDebugMode = Foundation.kDebugMode;
const bool kNotDebugMode = !kDebugMode;

class AppKeys {
  static const title = 'POLOCATOR';
}

class RouteName {
  static const pageHome = '/home';
  static const pageLogin = '/login';
  static const pageLocate = '/locate';
  static const pageAdd = '/add';
  static const pageTest = '/test';
}

class JS {
  static const firebaseConfigProxy = 'firebaseConfigProxy';
  static const vApIdKey = 'vApIdKey';
}
