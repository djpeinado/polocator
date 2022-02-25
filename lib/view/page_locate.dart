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
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

import '../controller/controller.dart';
import '../i18n/i18n.dart';
import '../misc/const.dart';
import '../misc/utils.dart';
import '../model/data.dart';

class LocatePage extends StatefulWidget {
  static const routeName = RouteName.pageLocate;
  @override
  _LocatePageState createState() => _LocatePageState();
}

class _LocatePageState extends State<LocatePage> {
  Completer<GoogleMapController> _controller = Completer();
  late String _email;
  StreamController<LocationResponse> _onLocateStreamController =
      StreamController<LocationResponse>();
  final Map<String, Marker> _markers = {};

  @override
  void dispose() {
    _onLocateStreamController.close();
    super.dispose();
  }

  Future<void> _onLocate(LocationResponse locationResponse) async {
    if (locationResponse.email == _email) {
      final GoogleMapController controller = await _controller.future;
      LatLng pos = LatLng(locationResponse.location.latitude!,
          locationResponse.location.longitude!);
      final MarkerId markerId = MarkerId(_email);
      setState(() {
        _markers.clear();
        final marker = Marker(
          markerId: markerId,
          position: pos,
          infoWindow: InfoWindow(
            title: _email,
            snippet: Utils.formatTimestamp(locationResponse.location.time!),
          ),
        );
        _markers[_email] = marker;
        controller.showMarkerInfoWindow(markerId);
      });
      final CameraPosition camPos =
          CameraPosition(target: pos, zoom: Maps.ZOOM_DEFAULT);
      controller.animateCamera(CameraUpdate.newCameraPosition(camPos));
    }
  }

  @override
  void didChangeDependencies() async {
    Controller.navigateToLoginIfNotLoggedIn(context);
    if (ModalRoute.of(context) != null &&
        ModalRoute.of(context)!.settings.arguments is String) {
      _email = ModalRoute.of(context)!.settings.arguments as String;
      //TODO: remove
      Future.delayed(Duration.zero, () {
        Utils.toast(context, "email: $_email");
      });
      _onLocateStreamController.stream.listen((locationResponse) {
        _onLocate(locationResponse);
      });
      Controller.setLocateStreamController(_onLocateStreamController);
      Controller.requestLocation(_email);
      // TODO loading
    } else {
      Utils.navigateTo(context, RouteName.pageHome, removeUntil: true);
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    LocationData? location = Controller.getLastLocation();
    double latitude =
        location != null && location.latitude != null ? location.latitude! : 0;
    double longitude = location != null && location.longitude != null
        ? location.longitude!
        : 0;
    double zoom = latitude != 0 && longitude != 0 ? Maps.ZOOM_DEFAULT : 0;
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(I18N.getString(I18N.keyLocateTitle)),
      ),
      body: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition:
            CameraPosition(target: LatLng(latitude, longitude), zoom: zoom),
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
        markers: _markers.values.toSet(),
      ),
    );
  }
}
