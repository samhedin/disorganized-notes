import 'package:timezone/browser.dart' as tz;

Future<void> initializeTimeZones() async {
  await tz.initializeTimeZone('assets/packages/timezone/data/latest.tzf');
}
