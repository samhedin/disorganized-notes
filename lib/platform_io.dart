import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

Future<String> saveFile(String fileName, String content) async {
    // Mobile (iOS/Android): Use 'path_provider' to save file
    try {
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(content);
      return file.path;
    } catch (e) {
      print("Error saving file: $e");
      return "";
    }
}


