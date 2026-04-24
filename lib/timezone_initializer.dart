export 'timezone_stub.dart'
    if (dart.library.html) 'timezone_browser.dart'
    if (dart.library.io) 'timezone_io.dart';
