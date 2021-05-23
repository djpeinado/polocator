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

import '../controller/controller.dart';
import '../i18n/i18n.dart';
import '../misc/const.dart';
import '../misc/utils.dart';

class LocatePage extends StatefulWidget {
  static const routeName = RouteName.pageLocate;
  @override
  _LocatePageState createState() => _LocatePageState();
}

class _LocatePageState extends State<LocatePage> {
  Completer<GoogleMapController> _controller = Completer();

  static final CameraPosition _kInit = CameraPosition(
    target: LatLng(0, 0),
  );

  @override
  void initState() {
    super.initState();
    final email = ModalRoute.of(context)!.settings.arguments as String;
    Utils.toast(context, "email: $email");
  }

  @override
  Widget build(BuildContext context) {
    Controller.navigateToLoginIfNotLoggedIn(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(I18N.getString(I18N.keyLocateTitle)),
      ),
      body: GoogleMap(
        mapType: MapType.hybrid,
        initialCameraPosition: _kInit,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      ),
    );
  }
}
