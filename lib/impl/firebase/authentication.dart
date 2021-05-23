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
// ignore: unused_import
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
//import '../../debug/google_sign_in.dart';

import '../../impl/firebase/core.dart';
import '../../interfaces.dart';
import '../../model/data.dart' as data;

class FirebaseAuthentication implements IAuth {
  FirebaseAuthentication._();
  static final FirebaseAuthentication instance = FirebaseAuthentication._();

  GoogleSignIn? _googleSignIn;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _resetGoogleSignIn() {
    var scopes = [
      'email',
      'https://www.googleapis.com/auth/contacts.readonly',
    ];
    _googleSignIn = GoogleSignIn(scopes: scopes);
  }

  Future<User?> _signInFirebase(GoogleSignInAccount googleSignInAccount) async {
    final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );

    // TODO remove
    // print(googleSignInAuthentication.accessToken);
    // print(googleSignInAuthentication.idToken);
    // print((await googleSignInAccount.authHeaders).toString());

    FirebaseCore.instance.init();

    final UserCredential userCrendential =
        await _auth.signInWithCredential(credential);
    final User user = userCrendential.user!;

    if (user.isAnonymous ||
        _auth.currentUser == null ||
        user.uid != _auth.currentUser!.uid) {
      return null;
    }
    return user;
  }

  @override
  Future<data.User?> signIn({bool silent = false}) async {
    if (_googleSignIn == null) {
      _resetGoogleSignIn();
    }
    GoogleSignInAccount? googleSignInAccount;
    try {
      if (silent) {
        googleSignInAccount = await _googleSignIn!.signInSilently();
      } else {
        googleSignInAccount = await _googleSignIn!.signIn();
      }
    } catch (error) {
      print('FirebaseAuthentication - Error: ' + error.toString());
      return null;
    }

    User? firebaseUser;
    if (googleSignInAccount != null) {
      firebaseUser = await _signInFirebase(googleSignInAccount);
    }
    if (firebaseUser != null) {
      data.User user = new data.User();
      user.id = firebaseUser.uid;
      user.email = firebaseUser.email;
      user.name = firebaseUser.displayName;
      user.name = firebaseUser.displayName;
      user.uid = firebaseUser.uid;
      return user;
    } else {
      signOut();
    }
    return null;
  }

  @override
  Future<void> signOut() async {
    await _googleSignIn!.signOut();
    await _auth.signOut();
    _resetGoogleSignIn();
  }

  @override
  bool isLoggedIn() {
    return _auth.currentUser != null;
  }

  Future<Map<String, String>> getAuthHeaders() async {
    if (_googleSignIn!.currentUser != null) {
      return _googleSignIn!.currentUser!.authHeaders;
    }
    return <String, String>{};
  }

  @override
  String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }
}
