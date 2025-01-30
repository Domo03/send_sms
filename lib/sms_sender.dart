import 'dart:async';

import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

class SmsSender {
  static const MethodChannel _channel = MethodChannel('sms_sender');

  static Future<List<Map<String, dynamic>>> getSimCards() async {
    try {
      var status = await Permission.sms.status;
      // Check and request phone state permission (for SIM card info)
      status = await Permission.phone.status;
      if (!status.isGranted) {
        status = await Permission.phone.request();
        if (!status.isGranted) {
          throw Exception("Phone permission denied");
        }
      }

      final List<dynamic> simCards = await _channel.invokeMethod('getSimCards');
      return simCards.map((dynamic item) {
        final map =
            item as Map<dynamic, dynamic>; // Cast to Map<dynamic, dynamic>
        return map.map<String, dynamic>(
            (key, value) => MapEntry(key.toString(), value));
      }).toList();
    } on PlatformException catch (e) {
      throw Exception("Failed to get SIM cards: ${e.message}");
    }
  }

  static Future<bool> sendSms(String phoneNumber, String message,
      {int? simSlot}) async {
    // Check and request SMS permission
    var status = await Permission.sms.status;
    if (!status.isGranted) {
      status = await Permission.sms.request();
      if (!status.isGranted) {
        throw Exception("SMS permission denied");
      }
    }

    // Check and request phone state permission (for SIM card info)
    status = await Permission.phone.status;
    if (!status.isGranted) {
      status = await Permission.phone.request();
      if (!status.isGranted) {
        throw Exception("Phone permission denied");
      }
    }

    try {
      await _channel.invokeMethod('sendSms', {
        'phoneNumber': phoneNumber,
        'message': message,
        'simSlot': simSlot,
      });
      return true;
    } on PlatformException catch (e) {
      throw Exception("${e.message}");
    }
  }

  static Future<void> checkSms() async {
    // Check and request SMS permission
    var status = await Permission.sms.status;
    if (!status.isGranted) {
      status = await Permission.sms.request();
      if (!status.isGranted) {
        throw Exception("SMS permission denied");
      }
    }

    // Check and request phone state permission (for SIM card info)
    status = await Permission.phone.status;
    if (!status.isGranted) {
      status = await Permission.phone.request();
      if (!status.isGranted) {
        throw Exception("Phone permission denied");
      }
    }
  }
}
