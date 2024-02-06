import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:zerotech_utilities/src/zerotech_utilities.dart';
import 'package:zerotech_utilities/utilities.dart';

void main() {
  group('Utilities', () {
    setUp(() => () {
          Get.testMode = true;
        });
    test('setLocale sets the correct locale', () {
      // Set up
      SFUtilities utilities = Utilities();
      Locale expectedLocale = Locale('sr', 'SR');

      // Execute
      utilities.updateLocale('sr_SR');

      // Verify
      expect(Get.locale, expectedLocale);
    });
  });
}
