import 'package:web/web.dart'; // or dart:html if you're not on Flutter 3.16+

void myPluginDownload(String url) {
  final anchor = HTMLAnchorElement()
    ..href = url
    ..download = url
    ..click();
}
