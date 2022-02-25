// ignore: avoid_web_libraries_in_flutter
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
import 'dart:ui';

import 'package:collection/collection.dart' show IterableExtension;
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../e2ee/e2ee.dart' as e2ee;
import '../misc/const.dart';
import '../misc/crc.dart';
import '../ui/style.dart';

class Utils {
  static String color2HTML(Color color, {withAlpha: true}) {
    String red = color.red.toRadixString(16);
    String green = color.green.toRadixString(16);
    String blue = color.blue.toRadixString(16);
    String alpha = withAlpha ? color.alpha.toRadixString(16) : '';
    return '#$red$green$blue$alpha';
  }

  static double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static void toast(BuildContext context, String message,
      {bool hideCurrent: false}) {
    SnackBarBehavior behavior = SnackBarBehavior.floating;
    Text text = Text(message);
    SnackBar snackBar;
    if (getScreenWidth(context) > Style.maxWidthToast) {
      snackBar = SnackBar(
        content: text,
        behavior: behavior,
        width: Style.maxWidthToast,
      );
    } else {
      snackBar = SnackBar(
        content: text,
        behavior: behavior,
      );
    }
    if (hideCurrent) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
    }
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static void snack(BuildContext context, String message,
      {bool hideCurrent: false}) {
    if (hideCurrent) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  static void navigateTo(context, String routeName,
      {bool removeUntil = false, String? param}) {
    if (removeUntil) {
      Navigator.pushNamedAndRemoveUntil(context, routeName, (_) => false,
          arguments: param);
    } else {
      Navigator.pushNamed(context, routeName, arguments: param);
    }
  }

  static bool isValidEmail(String value) {
    return RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(value);
  }

  static T? enumFromString<T>(Iterable<T> values, String? value) {
    return values
        .firstWhereOrNull((type) => type.toString().split(".").last == value);
  }

  static String enumToString<T>(T value) {
    return value.toString().split(".").last;
  }

  static Future<encrypt.Encrypter> getEncryptor(
      String keyPrivate, String keyPublic) async {
    String sharedSecret = (await e2ee.X25519().calculateSharedSecret(
            e2ee.Key.fromBase64(keyPrivate, false),
            e2ee.Key.fromBase64(keyPublic, true)))
        .toBase64();
    final key = encrypt.Key.fromBase64(sharedSecret);
    return new encrypt.Encrypter(encrypt.Salsa20(key));
  }

  static Future<String> encryptWithCRC(
      String keyPrivate, String keyPublic, String input) async {
    try {
      encrypt.Encrypter cryptor = await getEncryptor(keyPrivate, keyPublic);
      final iv = encrypt.IV.fromLength(Crypto.IV_LENGTH);
      String encrypted = cryptor.encrypt(input, iv: iv).base64;
      int crc = CRC32.compute(input);
      String crcSep = Crypto.CRC_SEPARATOR;
      return "$encrypted$crcSep$crc";
    } catch (e) {
      return '';
    }
  }

  static Future<String> decryptWithCRC(
      String keyPrivate, String keyPublic, String input) async {
    try {
      if (input.contains(Crypto.CRC_SEPARATOR)) {
        int idx = input.lastIndexOf(Crypto.CRC_SEPARATOR);
        String msgPart = input.substring(0, idx);
        String crcPart = input.substring(idx + 1);
        int? crc = int.tryParse(crcPart);
        if (crc != null) {
          print(
              "######### decryptWithCRC(): msgPart=$msgPart crcPart=$crcPart");
          encrypt.Encrypter cryptor = await getEncryptor(keyPrivate, keyPublic);
          final iv = encrypt.IV.fromLength(Crypto.IV_LENGTH);
          msgPart =
              cryptor.decrypt(encrypt.Encrypted.fromBase64(msgPart), iv: iv);
          int crcComp = CRC32.compute(msgPart);
          print("######### decryptWithCRC(): msgPartDec=$msgPart");
          print("######### decryptWithCRC(): crcComp=$crcComp");
          if (crcComp == crc) return msgPart;
        }
      }
    } on FormatException {
      return '';
    }
    return '';
  }

  static String formatTimestamp(double timestamp) {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp.toInt());
    return DateFormat('dd/MM HH:mm').format(dateTime);
  }
}
