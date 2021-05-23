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
import 'package:cloud_functions/cloud_functions.dart' as cloudFunctions;

import '../../interfaces.dart';
import '../../model/data.dart';
import 'authentication.dart';

class FirebaseFunctions implements IAppService {
  FirebaseFunctions._() {
    // TODO: Remove emulator
    cloudFunctions.FirebaseFunctions.instance
        .useFunctionsEmulator(origin: '//localhost:5001');
  }
  static final FirebaseFunctions instance = FirebaseFunctions._();

  @override
  Future<Contacts?> getContacts() async {
    print("########## getAppContacts()");
    Map<String, String> authHeaders =
        await FirebaseAuthentication.instance.getAuthHeaders();
    //print(authHeaders.toString());
    final cloudFunctions.HttpsCallable callable =
        cloudFunctions.FirebaseFunctions.instance.httpsCallable(
      'app_contacts',
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
}
