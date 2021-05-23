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
import 'package:flutter/material.dart';

import '../factory.dart';

class AppThemeMode with ChangeNotifier {
  static const keyThemeMode = 'theme_mode';

  static final AppThemeMode instance = AppThemeMode();

  static bool? _isDarkMode;

  AppThemeMode() {
    _isDarkMode = implStorageLocal.get(keyThemeMode, defaultValue: false);
  }

  static ThemeMode getCurrentThemeMode() {
    return _isDarkMode! ? ThemeMode.dark : ThemeMode.light;
  }

  static bool? get isDarkMode => _isDarkMode;

  static void switchThemeMode() {
    _isDarkMode = !_isDarkMode!;
    implStorageLocal.write(keyThemeMode, _isDarkMode);
    instance.notifyListeners();
  }
}
