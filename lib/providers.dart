import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_ui_oauth_apple/firebase_ui_oauth_apple.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';


class CAppleProvider extends AppleProvider {
  CAppleProvider() : super();

  @override
  bool get shouldUpgradeAnonymous => false;
}

class CGoogleProvider extends GoogleProvider {
  CGoogleProvider()
      : super(
          clientId: (!kIsWeb && Platform.isIOS)
              ? '989769042149-46c4m1b144k01fdav1lf49h7redkc2gc.apps.googleusercontent.com'
              : '989769042149-e3onm9bvou4g08c8b9s6lu8h7341ro8b.apps.googleusercontent.com',
        );
  @override
  bool get shouldUpgradeAnonymous => false;

}


class CEmailAuthProvider extends EmailAuthProvider {
  CEmailAuthProvider() : super();

  @override
  bool get shouldUpgradeAnonymous => false;
}
