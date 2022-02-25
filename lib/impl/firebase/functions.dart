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

import 'package:cloud_functions/cloud_functions.dart' as cloudFunctions;
//import 'package:googleapis/cloudresourcemanager/v1.dart';
import 'package:location/location.dart' as loc;

import '../../controller/controller.dart';
import '../../interfaces.dart';
import '../../controller/location.dart';
import '../../misc/const.dart';
import '../../misc/utils.dart';
import '../../model/data.dart';
import '../../model/model.dart';
import 'authentication.dart';
import 'core.dart';

class FirebaseFunctions implements IAppService {
  FirebaseFunctions._();
  static final FirebaseFunctions instance = FirebaseFunctions._();

  @override
  Future<Contacts?> getContacts() async {
    FirebaseCore.instance.init();
    print("########## getAppContacts()");
    Map<String, String> authHeaders =
        await FirebaseAuthentication.instance.getAuthHeaders();
    //print(authHeaders.toString());
    final cloudFunctions.HttpsCallable callable =
        cloudFunctions.FirebaseFunctions.instance.httpsCallable(
      Functions.opGetContacts,
    );
    cloudFunctions.HttpsCallableResult resp =
        await callable.call(<String, dynamic>{
      'token': authHeaders['Authorization']!.replaceAll('Bearer ', ''),
    });
    print("########## getAppContacts() after request");
    Contacts contacts = new Contacts();
    contacts.all = [];
    contacts.app = [];
    var contactsJS = resp.data['contacts'];
    if (contactsJS != null) {
      for (var contactData in contactsJS) {
        var contactName = contactData['name'];
        var contactEmail = contactData['email'];
        var contactSignedIn = contactData['signedIn'];
        if (contactName != null && contactEmail != null) {
          Contact contact = new Contact();
          contact.name = contactName;
          contact.email = contactEmail;
          //print("########## contact #################");
          //print("########## contact.name = ${contact.name}");
          //print("########## contact.email = ${contact.email}");
          contacts.all.add(contact);
          if (contactSignedIn != null && contactSignedIn) {
            contacts.app.add(contact);
          }
        }
      }
    }
    return contacts;
  }

  @override
  Future<bool> requestLocation(
      String emailTarget, String email, String keyPublic) async {
    FirebaseCore.instance.init();
    print("########## requestLocation()");
    final cloudFunctions.HttpsCallable callable =
        cloudFunctions.FirebaseFunctions.instance.httpsCallable(
      Functions.opRequestLocation,
    );
    cloudFunctions.HttpsCallableResult resp =
        await callable.call(<String, dynamic>{
      User.keyEmailTarget: emailTarget,
      User.keyEmail: email,
      User.keyEncryptionKeyPublic: keyPublic
    });
    print("########## requestLocation() after request");
    return resp.data != null && resp.data is bool && resp.data == true;
  }

  @override
  Future<bool> sendLocation(
      String emailTarget, String keyPublic, String keyPrivate) async {
    FirebaseCore.instance.init();
    print("########## sendLocation()");
    String? keyPublicCurrent = Model.getKeyPublic();
    print("########## sendLocation: keyPublicCurrent=$keyPublicCurrent");
    print("########## sendLocation: keyPublic=$keyPublic");
    print("########## sendLocation: keyPrivate=$keyPrivate");
    String? email = await Model.getEmail();
    if (email != null) {
      HashMap<String, ConnectionStatus?>? connections =
          await Model.getConnections();
      if (connections != null &&
          connections.containsKey(emailTarget) &&
          connections[emailTarget] == ConnectionStatus.ALLOWED) {
        loc.LocationData? location = await Controller.getLocation();
        if (location != null) {
          // Let's encrypt location
          String locationString = Location.serialize(location);
          print("########## sendLocation():  locationString = $locationString");
          String data =
              await Utils.encryptWithCRC(keyPrivate, keyPublic, locationString);
          print("########## sendLocation():  data = $data");
          final cloudFunctions.HttpsCallable callable =
              cloudFunctions.FirebaseFunctions.instance.httpsCallable(
            Functions.opSendLocation,
          );
          cloudFunctions.HttpsCallableResult resp =
              await callable.call(<String, dynamic>{
            User.keyEmailTarget: emailTarget,
            User.keyEmail: email,
            User.keyEncryptionKeyPublic: keyPublicCurrent,
            Functions.keyData: data
          });
          print("########## sendLocation() after request");
          return resp.data != null && resp.data is bool && resp.data == true;
        } else {
          print("sendLocation: Cannot get current location");
          return false;
        }
      } else {
        print(
            "sendLocation: Won't send location, connection NOT ALLOWED with $emailTarget");
        return false;
      }
    } else {
      print("sendLocation: Won't send location, cannot get current user email");
      return false;
    }
  }
}
