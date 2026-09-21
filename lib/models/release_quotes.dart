import 'dart:convert';
import 'dart:math';
import 'package:get/get.dart';
import '../db_confetti/data.dart';
class ReleaseQuotes {
  static const List<String> items = [
    'The secret locked in old drawers, unlocked here.',
    'What weighs a thousand pounds can vanish in seconds.',
    'You let it go. That takes courage.',
    'The storm passed. You\'re still standing.',
    'Words written, words released. Nothing left to carry.',
    'Every ending is just the space before something lighter.',
    'It happened. Now it\'s gone. And you remain.',
    'Ash returns to earth. Feelings return to silence.',
    'You gave it form. You gave it an ending. Well done.',
    'The fire that burned you also set you free.',
    'Sometimes releasing is the bravest thing you can do.',
    'It was real. And now it\'s done.',
    'You didn\'t run from it. You faced it, then let it go.',
    'Like smoke into open air — dissolved, never lost.',
    'One less thing to hold. One more step forward.',
    'You chose to release, not to replay. That\'s wisdom.',
    'Heavy things don\'t have to stay heavy forever.',
    'It existed. You acknowledged it. Now it\'s free.',
    'Letting go isn\'t losing — it\'s choosing space.',
    'The weight is lifted. The moment is yours.',
    'You showed up for yourself today.',
    'Not every feeling needs to be carried home.',
    'What you released no longer defines you.',
    'The quieter you become, the more you can hear.',
    'You were bigger than what was weighing you down.',
    'A breath in. A breath out. It\'s already lighter.',
    'Destruction can be the kindest form of closure.',
    'It left. And something else is quietly arriving.',
    'There\'s strength in the act of letting something burn.',
    'You made space. That space is yours now.',
  ];
  static const List<int> intensities = [
    0, 2, 1, 2, 1, 0, 1, 2, 1, 2,
    1, 1, 1, 0, 0, 1, 2, 1, 0, 2,
    1, 0, 2, 0, 2, 0, 2, 0, 2, 0,
  ];
  static Future<String> takeNext({int? intensity}) async {
    try {
      final db = Get.find<ConfettiDatabase>();
      final pref = await db.getPreference();
      if (pref == null) return items[0];
      final order = List<int>.from(
        (jsonDecode(pref.quoteOrder) as List).cast<int>(),
      );
      final index = pref.quoteIndex.clamp(0, items.length - 1);
      if (intensity != null) {
        final len = order.length;
        var found = -1;
        for (var step = 0; step < len; step++) {
          final i = (index + step) % len;
          if (intensities[order[i]] == intensity) {
            found = i;
            break;
          }
        }
        if (found >= 0 && found != index) {
          final tmp = order[index];
          order[index] = order[found];
          order[found] = tmp;
        }
      }
      final quote = items[order[index]];
      var newIndex = index + 1;
      var newOrder = order;
      if (newIndex >= items.length) {
        newOrder = List<int>.generate(items.length, (i) => i)..shuffle(Random());
        newIndex = 0;
      }
      await db.updatePreference(pref.copyWith(
        quoteOrder: jsonEncode(newOrder),
        quoteIndex: newIndex,
      ));
      return quote;
    } catch (_) {
      return items[Random().nextInt(items.length)];
    }
  }
}
