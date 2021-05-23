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

import '../../interfaces.dart';

class FirebaseCloudMessaging implements IPushNotifications {
  static final FirebaseCloudMessaging instance = FirebaseCloudMessaging();

  @override
  Future<String?> getId() async {
    throw UnsupportedError('Unsupported method FirebaseCloudMessaging.getId()');
  }

  @override
  void setRefreshIdHandler(Function(String) f) {
    throw UnsupportedError(
        'Unsupported method FirebaseCloudMessaging.setRefreshIdHandler()');
  }

  @override
  void setMessageHandler(Function f) {
    throw UnsupportedError(
        'Unsupported method FirebaseCloudMessaging.setMessageHandler()');
  }
}
