import 'dart:typed_data';
import 'dart:ui';

import 'package:get/get.dart';
import 'package:stepfront_utilities/src/app_colors.dart';
import 'dart:io';

import 'package:stepfront_utilities/src/stepfront_exception_model.dart';

class Utilities {
  void setLocale(String languageCode) {
    List<String> languageCodeList = languageCode.split("_");
    String language = languageCodeList[0]; // "sr"
    String country = languageCodeList[1]; // "SR"
    Get.updateLocale(Locale(language, country));
  }

  bool displaySFExceptionSnackbar(String errorAsString) {
    SFExceptionModel exceptionModel =
        SFExceptionModel.fromString(errorAsString);
    Color backgroundColor = decideBackgroundColor(exceptionModel.status ?? 0);
    if (exceptionModel.detail.toString().length > 450) {
      Get.snackbar("SomethingWentWrong".tr,
          exceptionModel.detail.toString().substring(0, 450),
          colorText: AppColors.white, backgroundColor: backgroundColor);
      return true;
    }
    Get.snackbar("SomethingWentWrong".tr, exceptionModel.detail.toString(),
        colorText: AppColors.white, backgroundColor: backgroundColor);
    return true;
  }

  void displayStringSnackbar(String errorAsString) {
    if (errorAsString.toString().length > 450) {
      Get.snackbar(
          "SomethingWentWrong".tr, errorAsString.toString().substring(0, 450),
          colorText: AppColors.white, backgroundColor: AppColors.red);
      return;
    }
    Get.snackbar("SomethingWentWrong".tr, errorAsString.toString(),
        colorText: AppColors.white, backgroundColor: AppColors.red);
    return;
  }

  void displayFriendlyUserSnackbar(String title, String message) {
    Get.snackbar(title, message,
        colorText: AppColors.white, backgroundColor: AppColors.yellow);
    return;
  }

  static singleChoiceCheckBox(List<bool> checkBoxes, int listOrder) {
    // Set the checkBox active
    checkBoxes[listOrder] = true;
    // Find the checkBoxes that are active and de-activate them.
    // Exception: "this" checkBox
    for (var i = 0; i < checkBoxes.length; i++) {
      if (checkBoxes[i] && listOrder != i) {
        checkBoxes[i] = false;
      }
    }
  }

  Color decideBackgroundColor(int status) {
    if (status == 404 || (status >= 500 && status < 600)) {
      return AppColors.red;
    } else if (status == 400) {
      return AppColors.yellow;
    } else {
      return AppColors.white;
    }
  }

  void updateLocale(String languageChoice) {
    List<String> parts = languageChoice.split("_");

    String languageCode = parts[0]; // "en"
    String countryCode = parts[1]; // "US"

    Get.updateLocale(Locale(languageCode, countryCode));
    return;
  }
}
