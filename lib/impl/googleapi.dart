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
import 'package:googleapis/people/v1.dart';
import 'package:http/browser_client.dart';
import 'package:http/http.dart';
import 'package:http/io_client.dart';

import '../impl/firebase/authentication.dart';
import '../misc/const.dart';
import '../model/data.dart';

class GoogleHttpClient extends IOClient {
  Map<String, String> _headers;

  GoogleHttpClient(this._headers) : super();

  @override
  Future<IOStreamedResponse> send(BaseRequest request) =>
      super.send(request..headers.addAll(_headers));

  @override
  Future<Response> head(Object url, {Map<String, String>? headers}) =>
      super.head(url as Uri, headers: headers?..addAll(_headers));
}

class GoogleHttpBrowserClient extends BrowserClient {
  Map<String, String> _headers;

  GoogleHttpBrowserClient(this._headers) : super();

  @override
  Future<IOStreamedResponse> send(BaseRequest request) =>
      super.send(request..headers.addAll(_headers))
          as Future<IOStreamedResponse>;

  @override
  Future<Response> head(Object url, {Map<String, String>? headers}) =>
      super.head(url as Uri, headers: headers?..addAll(_headers));
}

class GoogleApi {
  GoogleApi._();
  static final GoogleApi instance = GoogleApi._();

  Future<List<Contact>?> getContacts() async {
    // custom IOClient from below

    print("########## getContacts() start");
    if (!FirebaseAuthentication.instance.isLoggedIn()) return null;

    Map<String, String> authHeaders =
        await FirebaseAuthentication.instance.getAuthHeaders();

    final httpClient = kIsWeb
        ? GoogleHttpBrowserClient(authHeaders)
        : GoogleHttpClient(authHeaders);

    ListConnectionsResponse data = await PeopleServiceApi(httpClient)
        .people
        .connections
        .list('people/me', personFields: 'names,emailAddresses');

    print("########## getContacts() after request");

    List<Contact> contacts = [];
    for (Person person in data.connections!) {
      if (person.names != null && person.emailAddresses != null) {
        // Contact contact = new Contact();
        // contact.name = person.names.toString();
        // contact.email = person.emailAddresses.first.value;
        // contacts.add(contact);
        print("########## person.names=" + person.names!.first.displayName!);
        print("########## person.emailAddresses=" +
            person.emailAddresses!.first.value!);
      }
    }
    return contacts;
  }
}
