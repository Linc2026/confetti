import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
bool localTimezoneReady = false;
Future<void> initLocalTimezone() async {
  tzdata.initializeTimeZones();
  try {
    final name = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(name));
    localTimezoneReady = true;
  } catch (_) {
    localTimezoneReady = false;
  }
}
