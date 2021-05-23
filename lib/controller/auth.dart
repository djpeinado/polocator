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
import '../factory.dart';
import '../model/model.dart';

class Auth {
  Auth._();
  static final Auth instance = Auth._();

  bool _isSignInSilentlyDone = false;

  bool get isSignInSilentlyDone => _isSignInSilentlyDone;

  Future<User?> signIn({bool silent = false}) async {
    User? user;
    if (silent) {
      _isSignInSilentlyDone = true;
    }
    try {
      user = await implAuth.signIn(silent: silent);
    } catch (error) {
      print('Auth - Error: ' + error.toString());
      user = null;
    }
    return user;
  }

  Future<void> signOut() async {
    await implAuth.signOut();
  }

  bool isLoggedIn() {
    return implAuth.isLoggedIn();
  }
}
