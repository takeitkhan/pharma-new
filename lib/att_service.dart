
import 'package:flutter/services.dart';

class ATTService {
  static const platform = MethodChannel('app.tracking');

  static Future<bool> requestPermission() async {
    try {
      final result = await platform.invokeMethod('requestTracking');
      return result == 1; // 1 = authorized, 0 = denied
    } catch (e) {
      return false;
    }
  }
}
