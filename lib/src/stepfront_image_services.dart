import "dart:ui" as ui;
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:path/path.dart';

/// ! DO NOT REMOVE, CRASHES iOS!!!!!!!!!!
/// ignore: unnecessary_import
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

/// ! DO NOT REMOVE, CRASHES iOS!!!!!!!!!!

abstract class SFImageServices {
  /// This method should be overridden to create a marker icon.
  /// Example use:
  /// ```dart
  /// BitmapDescriptor.fromBytes(
  /// await ImageStyles().getCustomerIcon(
  ///   100.w.toInt(),
  ///   100.h.toInt(),
  ///   markerIndex,
  ///   color,
  ///  ),
  ///);
  /// ```
  Future<Uint8List> createMarkerIcon();

  static SvgPicture svgImage(String svgTitle, [Color? color]) {
    return SvgPicture.asset(
      "assets/svg/$svgTitle.svg",
      colorFilter:
          color == null ? null : ColorFilter.mode(color, BlendMode.color),
      /* color: Colors.blueAccent, */
    );
  }

  static Image pngImage(String pngTitle) {
    return Image.asset(
      "assets/png/$pngTitle.png",
    );
  }

  /* 
  * TODO: Do this.
  * We want to have three different routes:
  * inactive routes(They will be inactive if they are not the next route to be delivered.)
  * active routes (They will be active if they are the next route to be delivered.)
  * * * There will be 3 separate states for this. In Progress, Late, Undelivered.
  * Delivered routes (They will be blue-ish if they have been already delivered to.)
  */
  /* https://stackoverflow.com/questions/60019684/use-gradient-with-paint-object-in-flutter-canvas */
  Future<Uint8List> getBytesFromCanvasForTextStandard(
      int width, int height, int index) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint paint = Paint()..color = Colors.blue;
    const Radius radius = Radius.circular(20.0);
    canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(0.0, 0.0, width.toDouble(), height.toDouble()),
          topLeft: radius,
          topRight: radius,
          bottomLeft: radius,
          bottomRight: radius,
        ),
        paint);
    TextPainter painter = TextPainter(textDirection: TextDirection.ltr);
    painter.text = TextSpan(
      text: '$index',
      style: const TextStyle(fontSize: 50.0, color: Colors.white),
    );
    painter.layout();
    painter.paint(
        canvas,
        Offset((width * 0.5) - painter.width * 0.5,
            (height * 0.5) - painter.height * 0.5));
    final img = await pictureRecorder.endRecording().toImage(width, height);
    final data = await img.toByteData(format: ui.ImageByteFormat.png);
    return data!.buffer.asUint8List();
  }

  Future<Widget> _avatarFromImageUrl(String cdnURL, String picturePath,
      {Size? size, BoxDecoration? decoration}) async {
    try {
      final response = await http.get(Uri.parse('$cdnURL$picturePath'));
      final documentDirectory = await getApplicationDocumentsDirectory();

      final file =
          _decideFileTypeForProfilePicture(documentDirectory, picturePath);

      file.writeAsBytesSync(response.bodyBytes);

      return ClipRRect(
        child: Container(
          width: size?.width ?? 98.w,
          height: size?.height ?? 98.h,
          decoration: decoration ??
              BoxDecoration(borderRadius: BorderRadius.circular(15)),
          child: Image(image: FileImage(file)),
        ),
      );
    } catch (e) {
      throw Exception();
    }
  }

  FutureBuilder<Widget> buildAvatarFromImageUrl(
      String cdnURL, String picturePath,
      {Size? size, BoxDecoration? decoration}) {
    return FutureBuilder<Widget>(
      future: _avatarFromImageUrl(cdnURL, picturePath,
          size: size, decoration: decoration),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return snapshot.requireData;
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  File _decideFileTypeForProfilePicture(
      Directory documentDirectory, String picturePath) {
    if (picturePath.contains(".png")) {
      return File(join(documentDirectory.path, 'profile.png'));
    } else if (picturePath.contains(".jpg")) {
      return File(join(documentDirectory.path, 'profile.jpg'));
    }

    /// Default
    else {
      return File(join(documentDirectory.path, 'profile.png'));
    }
  }

  Future<File> convertJpgToPng(File jpgFile) async {
    // Read the JPEG file as bytes
    Uint8List jpegBytes = await jpgFile.readAsBytes();

    // Decode the JPEG bytes into an image object
    img.Image jpgImage = img.decodeJpg(jpegBytes)!;

    // Convert the JPEG image object to PNG format
    img.Image pngImage = img.copyResize(jpgImage,
        width: jpgImage.width, height: jpgImage.height);
    List<int> pngBytes = img.encodePng(pngImage);

    // Save the PNG bytes to a new file
    String newPath = jpgFile.path.replaceAll('.jpg', '.png');
    File pngFile = File(newPath);
    await pngFile.writeAsBytes(pngBytes);

    return pngFile;
  }
}
