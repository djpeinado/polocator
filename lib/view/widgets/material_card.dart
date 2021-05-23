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
import 'package:flutter/material.dart';
import '../../ui/style.dart';

class MaterialCard extends StatefulWidget {
  final String title;
  final String secondaryText;
  final String? actionButtonText1;
  final String? actionButtonText2;
  final void Function()? onActionButtonPressed1;
  final void Function()? onActionButtonPressed2;

  @override
  _MaterialCardState createState() => _MaterialCardState();

  const MaterialCard(
      {String title: "",
      String secondaryText: "",
      String? actionButtonText1,
      String? actionButtonText2,
      void Function()? onActionButtonPressed1,
      void Function()? onActionButtonPressed2})
      : this.title = title,
        this.secondaryText = secondaryText,
        this.actionButtonText1 = actionButtonText1,
        this.actionButtonText2 = actionButtonText2,
        this.onActionButtonPressed1 = onActionButtonPressed1,
        this.onActionButtonPressed2 = onActionButtonPressed2,
        super();
}

class _MaterialCardState extends State<MaterialCard> {
  @override
  void initState() {
    super.initState();
  }

  Widget actionButton(String text, {void Function()? onPressed}) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.only(
            left: 16.0, right: 18.0, top: 18.0, bottom: 18.0),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4.0),
            side: BorderSide(color: Colors.red)),
        textStyle: TextStyle(
          letterSpacing: 1.18,
        ),
      ),
      child: Text(text),
    );
  }

  void addActionButton(List<Widget> actionButtons, String? actionButtonText,
      void Function()? onActionButtonPressed) {
    if (actionButtonText != null && actionButtonText.isNotEmpty) {
      actionButtons.add(
          actionButton(actionButtonText, onPressed: onActionButtonPressed));
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> actionButtons = [];
    addActionButton(
        actionButtons, widget.actionButtonText1, widget.onActionButtonPressed1);
    addActionButton(
        actionButtons, widget.actionButtonText2, widget.onActionButtonPressed2);
    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: Style.getMaxWidthWidget()),
        margin: EdgeInsets.only(right: 10, left: 10, top: 10),
        child: Card(
          child: Container(
            margin: EdgeInsets.only(right: 0, left: 0, top: 0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  title: new Text(widget.title),
                  subtitle: new Text(widget.secondaryText),
                  leading: new Icon(Icons.person),
                ),
                ButtonBar(
                  alignment: MainAxisAlignment.start,
                  children: actionButtons,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
