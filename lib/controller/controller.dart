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
import 'package:flutter/widgets.dart';

import '../factory.dart';
import '../i18n/i18n.dart';
import '../misc/const.dart';
import '../misc/utils.dart';
import '../model/model.dart';
import 'auth.dart';

class Controller {
  Controller._();
  static final Controller instance = Controller._();

  static Future<bool> isLoggedIn() async {
    return Auth.instance.isLoggedIn() && await Model.isDeviceIdCurrentUser();
  }

  static void navigateToLoginIfNotLoggedIn(context) async {
    if (!await isLoggedIn()) {
      Utils.navigateTo(context, RouteName.pageLogin);
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
        Utils.toast(context, I18N.getString(I18N.keyLoginSuccess));
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
}
