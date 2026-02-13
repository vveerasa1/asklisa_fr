import 'dart:developer';

import 'package:flutter/foundation.dart';

class Log {
  static void d(var v) {
    if (kDebugMode) {
      log("AM : ${v.toString()}");
    }
  }
}
