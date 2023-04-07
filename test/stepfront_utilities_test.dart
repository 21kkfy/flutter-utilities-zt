import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:stepfront_utilities/stepfront_utilities.dart';

void main() {
  group('Utilities', () {
    setUp(() => () {
          Get.testMode = true;
        });
    test('setLocale sets the correct locale', () {
      // Set up
      Utilities utilities = Utilities();
      Locale expectedLocale = Locale('sr', 'SR');

      // Execute
      utilities.setLocale('sr_SR');

      // Verify
      expect(Get.locale, expectedLocale);
    });
  });
}
