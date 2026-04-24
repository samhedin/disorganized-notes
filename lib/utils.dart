import 'dart:core';
import 'secrets.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/foundation.dart';
import 'web_download.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:permission_handler/permission_handler.dart';
import 'package:collection/collection.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

void invalidNoteError(Map<dynamic,dynamic> note, String reason) async {
  print("Logging invalid note");
  await FirebaseCrashlytics.instance.recordError(
    Exception("Invalid note"),
    null,
    reason: reason,
    information: [note],
  );
}

Future<bool> requestMicrophonePermission() async {
  return await Permission.microphone.request().isGranted;
}

Future<void> checkAndroidScheduleExactAlarmPermission() async {
  final status = await Permission.scheduleExactAlarm.status;
  if (status.isDenied) {
    final res = await Permission.scheduleExactAlarm.request();
  }
}


/// Returns PNG bytes of an image filled with [color].
/// [width] and [height] are pixels. Optionally supply [pixelRatio] for higher-res images.
Future<Uint8List> imageFromColor({
  required Color color,
  required int width,
  required int height,
  double pixelRatio = 1.0,
}) async {
  assert(width > 0 && height > 0, 'Width/height must be > 0');

  final int w = (width * pixelRatio).round();
  final int h = (height * pixelRatio).round();

  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, w.toDouble(), h.toDouble()));

  final paint = Paint()..color = color;
  canvas.drawRect(Rect.fromLTWH(0, 0, w.toDouble(), h.toDouble()), paint);

  final picture = recorder.endRecording();
  final ui.Image img = await picture.toImage(w, h);
  final ByteData? pngBytes = await img.toByteData(format: ui.ImageByteFormat.png);
  return pngBytes!.buffer.asUint8List();
}


Future<bool> getSubscriptionStatusWeb(String user) async {
  try {
    Uri uri = Uri.https('api.revenuecat.com', '/v1/subscribers/$user');

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $revenueCatWeb',
      },
    ).timeout(const Duration(seconds: 1),
        onTimeout: () => throw TimeoutException('timeout'));

    if (response.statusCode == 200) {
      Map<String, dynamic> customerInfo = json.decode(response.body);
      Map<String, dynamic> entitlements =
          customerInfo['subscriber']['entitlements'];
      if (entitlements.isNotEmpty) {
        List<DateTime?> expiryDates = entitlements.values
            .map(
                (entitlement) => DateTime.tryParse(entitlement['expires_date']))
            .toList();
        return expiryDates.firstWhereOrNull(
                (element) => element!.isAfter(DateTime.now())) !=
            null;
      }
    }
    return false;
  } on TimeoutException {
    print("Call to get subscription status timed out");
    return true; // server took too long → assume true
  } catch (e) {
    debugPrint("Unable to retrieve subscriber status from Revenuecat: $e");
    return true;
  }
}

Future<void> writeToFile(ByteData data, String path) {
  final buffer = data.buffer;
  return new File(path)
      .writeAsBytes(buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
}

void downloadUrl(String url) {
  // when building in release the file structure changes ...
  myPluginDownload(url);
}

WidgetStateProperty<Color?> legibleTextColorForBackground(
    Color backgroundColor) {
  final luminance = backgroundColor.computeLuminance();
  final textColor = luminance > 0.5 ? Colors.black : Colors.white;

  return WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
    return textColor;
  });
}

void popUntilRoot(BuildContext context) {
  final goRouter = GoRouter.of(context);
  while (goRouter.canPop()) {
    goRouter.pop();
  }
}

RegExp tagsRegex() {
  return RegExp(r'[^\p{L}\p{N}\s!]', unicode: true);
}

Map<String, String> convertToStr(Map<dynamic, dynamic> m) {
  //Takes in a may of any values, calls tostring on all keys and values and returns the result.
  return m.map((key, value) => MapEntry(key.toString(), value.toString()));
}

Map<String, dynamic> stringKeys(Map<dynamic, dynamic> m) {
  return m.map((key, value) {
    final stringKey = key.toString();
    final stringValue = value is Map ? stringKeys(value) : value;
    return MapEntry(stringKey, stringValue);
  });
}

dynamic recursivelyStringifyKeys(dynamic value) {
  if (value is Map) {
    return value.map((key, val) => MapEntry(
          key.toString(),
          recursivelyStringifyKeys(val),
        ));
  } else if (value is List) {
    return value.map(recursivelyStringifyKeys).toList();
  } else {
    return value;
  }
}

Timer scheduleEveryMinute(Function callback) {
  return Timer.periodic(const Duration(minutes: 1), (_) => callback());
}

Map<String, dynamic> docSnapshotToMap(DocumentSnapshot snapshot) {
  if (!snapshot.exists) {
    return {"status": "empty"};
  }

  final data = snapshot.data();

  if (data is Map<String, dynamic>) {
    return data;
  } else {
    throw "Snapshot data is not a Map<String, dynamic>";
  }
}

List<Map<String, dynamic>?> CommentSnapshotToMaps(
    QuerySnapshot<Map<String, dynamic>> snapshot) {
  return snapshot.docs.map((doc) {
    final data = doc.data();
    if (data is Map<String, dynamic>) {
      return {
        ...data,
        'id': doc.id, // optionally include the document ID
      };
    }
    return null;
  }).toList();
}

Map<String, dynamic>? SnapshotToMap(
    AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
  if (snapshot.hasError) {
    throw "Snapshot has error";
  }
  if (snapshot.connectionState == ConnectionState.waiting) {
    return {"status": "waiting"};
  }
  if (!snapshot.hasData || !snapshot.data!.exists) {
    return {"status": "empty"};
  }
  var data = snapshot.data!.data();

  return snapshot.data!.data(); // Correctly returns a Map<String, dynamic>
}

Future<void> copyFolderInFirebaseStorage({
  required String sourceFolderPath,
  required String destinationFolderPath,
}) async {
  final storage = FirebaseStorage.instance;
  final sourceRef = storage.ref().child(sourceFolderPath);

  try {
    final listResult = await sourceRef.listAll();

    for (var item in listResult.items) {
      final fullSourcePath = item.fullPath;

      // Extract the file name only (the part after the last '/')
      final fileName = fullSourcePath.split('/').last;

      // Construct the full destination path
      final destinationPath = '$destinationFolderPath/$fileName';
      final destinationRef = storage.ref().child(destinationPath);

      // Download data from source
      final data = await item.getData();

      if (data != null) {
        await destinationRef.putData(data);
        print('Copied: $fullSourcePath -> $destinationPath');
      } else {
        print('Failed to download: $fullSourcePath');
      }
    }

    print('Folder copy complete!');
  } catch (e) {
    print('Error copying folder: $e');
  }
}
