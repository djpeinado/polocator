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
import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../interfaces.dart';
import '../../misc/utils.dart';
import '../../model/data.dart';

class FirebaseCloudStore implements IStorageCloud {
  FirebaseCloudStore._();
  static final FirebaseCloudStore instance = FirebaseCloudStore._();

  final CollectionReference _users =
      FirebaseFirestore.instance.collection(User.keyCollection);

  @override
  Future<bool> addUser(User user, List<int>? keySecure) async {
    try {
      await _users.doc(user.id).set({
        User.keyUid: user.uid,
        User.keyName: user.name,
        User.keyEmail: user.email,
        User.keyPushNotificationId: user.pushNotificationsId,
        User.keyDeviceId: user.deviceId,
        User.keyKeySecure: keySecure,
      }, SetOptions(merge: true));
    } catch (error) {
      print('FirebaseCloudStore - Error: ' + error.toString());
      return false;
    }
    return true;
  }

  @override
  Future<bool> existsUser(String? userId) async {
    // Check is already sign up
    try {
      final DocumentSnapshot doc = await _users.doc(userId).get();
      return doc.exists;
    } catch (error) {
      print('FirebaseCloudStore - Error: ' + error.toString());
      return false;
    }
  }

  @override
  Future<bool> updateUser(String? userId, Map<String, dynamic> data) async {
    try {
      await _users.doc(userId).set(data, SetOptions(merge: true));
      return true;
    } catch (error) {
      print('FirebaseCloudStore - Error: ' + error.toString());
      return false;
    }
  }

  Future<dynamic> getUserValue(String userId, String key) async {
    try {
      final DocumentSnapshot doc = await _users.doc(userId).get();
      if (doc.exists) {
        return doc.get(key);
      }
    } catch (error) {
      print('FirebaseCloudStore - Error: ' + error.toString());
    }
    return null;
  }

  @override
  Future<List<int>> getUserKeySecure(String userId) async {
    dynamic value = await getUserValue(userId, User.keyKeySecure);
    return value != null ? List<int>.from(value) : List.empty();
  }

  @override
  Future<String> getUserDeviceId(String userId) async {
    return await getUserValue(userId, User.keyDeviceId);
  }

  CollectionReference getUserCollectionConnections(String userId) {
    return FirebaseFirestore.instance.collection(
        "${User.keyCollection}/$userId/${Connection.keyCollection}");
  }

  @override
  Future<HashMap<String, ConnectionStatus?>> getConnections(
      String userId) async {
    final HashMap<String, ConnectionStatus?> connections =
        new HashMap<String, ConnectionStatus?>();

    try {
      final CollectionReference collection =
          getUserCollectionConnections(userId);
      final QuerySnapshot query = await collection.get();
      final List<QueryDocumentSnapshot> docs = query.docs;
      for (QueryDocumentSnapshot doc in docs) {
        String email = doc.id;
        String statusString = doc.get(Connection.keyStatus);
        ConnectionStatus? status =
            Utils.enumFromString(ConnectionStatus.values, statusString);
        connections[email] = status;
      }
    } catch (error) {
      print('FirebaseCloudStore - Error: ' + error.toString());
    }

    return connections;
  }

  @override
  Future<bool> setConnection(
      String userId, String email, ConnectionStatus status) async {
    try {
      final CollectionReference collection =
          getUserCollectionConnections(userId);
      Map<String, dynamic> data = {
        Connection.keyStatus: Utils.enumToString(status)
      };
      await collection.doc(email).set(data);
      return true;
    } catch (error) {
      print('FirebaseCloudStore - Error: ' + error.toString());
      return false;
    }
  }
}
