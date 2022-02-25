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
import 'dart:convert';

import 'package:location/location.dart' as loc;

class Location {
  Location._();
  static final Location instance = Location._();

  loc.LocationData? _locationData;

  Future<loc.LocationData?> getLocation() async {
    loc.Location location = new loc.Location();

    bool serviceEnabled;
    loc.PermissionStatus permissionGranted;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return null;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == loc.PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != loc.PermissionStatus.granted) {
        return null;
      }
    }

    _locationData = await location.getLocation();
    return _locationData;
  }

  loc.LocationData? getLastLocation() {
    return _locationData;
  }

  static String serialize(loc.LocationData location) {
    Map<String, dynamic> dataMap = Map<String, dynamic>();
    dataMap['latitude'] = location.latitude;
    dataMap['longitude'] = location.longitude;
    dataMap['accuracy'] = location.accuracy;
    dataMap['time'] = location.time;
    return jsonEncode(dataMap);
  }

  static loc.LocationData deserialize(String locationString) {
    Map<String, dynamic> map = jsonDecode(locationString);
    // Ensure all numeric values are set as doubles
    // (all LocationData variables are double)
    for (String key in map.keys) {
      dynamic value = map[key];
      if (!(value is double)) {
        if (value is num) {
          map[key] = value.toDouble();
        } else if (value is String) {
          double? vald = double.tryParse(value);
          if (vald != null) {
            map[key] = vald;
          }
        }
      }
    }
    return loc.LocationData.fromMap(map);
  }
}
