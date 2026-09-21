import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../components/confetti_discard_dialog.dart';
import '../../components/confetti_release_flow.dart';
import '../../utils/index.dart';
class WordCategory {
  final String name;
  final List<String> words;
  const WordCategory(this.name, this.words);
}
class WordPick {
  final String category;
  final String word;
  const WordPick(this.category, this.word);
}
class ConfettiWordJarLogic extends GetxController with ConfettiReleaseMixin {
  static const customCategory = 'Custom';
  final selectedKeys = <String>{}.obs;
  final customWords = <String>[].obs;
  final customInput = TextEditingController();
  bool _shredding = false;
  static const categories = [
    WordCategory('Rage', [
      'Furious', 'Fuming', 'Explosive', 'Seething',
      'Raging', 'Livid', 'Bitter', 'Resentful',
    ]),
    WordCategory('Sadness', [
      'Heartbroken', 'Empty', 'Hollow', 'Grief',
      'Shattered', 'Crushed', 'Hopeless', 'Weeping',
    ]),
    WordCategory('Anxiety', [
      'Panicking', 'Trapped', 'Spinning', 'Suffocating',
      'Nervous', 'Dreading', 'Restless', 'Overwhelmed',
    ]),
    WordCategory('Fatigue', [
      'Exhausted', 'Numb', 'Done', 'Burned out',
      'Heavy', 'Drained', 'Running on empty', 'Spent',
    ]),
    WordCategory('Isolation', [
      'Betrayed', 'Invisible', 'Forgotten', 'Alone',
      'Used', 'Disconnected', 'Abandoned', 'Left out',
    ]),
    WordCategory('Shame', [
      'Humiliated', 'Guilty', 'Embarrassed', 'Worthless',
      'Exposed', 'Ashamed', 'Small', 'Regret',
    ]),
    WordCategory('Envy', [
      'Jealous', 'Left behind', 'Unfair', 'Why them',
      'Not enough', 'Overlooked', 'Replaced', 'Resentful',
    ]),
    WordCategory('Confusion', [
      'Lost', 'Stuck', 'Uncertain', 'Directionless',
      'Fog', 'Overwhelmed', 'Pulled apart', 'Questioning',
    ]),
    WordCategory('Grief', [
      'Missing you', 'Gone', 'Too soon', 'Never again',
      'Hollow', 'Longing', 'Unfinished', 'Still hurts',
    ]),
    WordCategory('Relief', [
      'Finally', 'Let go', 'It\'s over', 'Lighter',
      'Free', 'Done', 'Safe', 'Exhale',
    ]),
  ];
  static const int _maxCustomWords = 10;
  static const int _maxWordLength = 20;
  int get totalSelected => selectedKeys.length;
  int get inkWeight {
    final n = selectedKeys.length;
    if (n <= 0) return 0;
    if (n <= 4) return 1;
    return 2;
  }
  static String selectionKey(String category, String word) =>
      '$category|$word';
  bool isSelected(String category, String word) =>
      selectedKeys.contains(selectionKey(category, word));
  List<String> get selectedWordLabels =>
      selectedEntries.map((e) => e.word).toList();
  List<WordPick> get selectedEntries {
    return selectedKeys.map((key) {
      final split = key.indexOf('|');
      return WordPick(key.substring(0, split), key.substring(split + 1));
    }).toList();
  }
  bool _isPresetWord(String word) {
    for (final cat in categories) {
      if (cat.words.contains(word)) return true;
    }
    return false;
  }
  void toggleWord(String category, String word) {
    if (releasePhase.value != ReleasePhase.idle) return;
    final key = selectionKey(category, word);
    if (selectedKeys.contains(key)) {
      selectedKeys.remove(key);
    } else {
      selectedKeys.add(key);
    }
    HapticFeedback.selectionClick();
  }
  void addCustomWord() {
    if (releasePhase.value != ReleasePhase.idle) return;
    final word = customInput.text.trim();
    if (word.isEmpty) return;
    if (word.length > _maxWordLength) {
      errorToast('Word must be ≤ $_maxWordLength characters.');
      return;
    }
    if (customWords.length >= _maxCustomWords) {
      errorToast('You can add up to $_maxCustomWords custom words.');
      return;
    }
    if (customWords.contains(word)) {
      errorToast('This word is already added.');
      return;
    }
    if (_isPresetWord(word)) {
      errorToast('This word is already in the jar.');
      return;
    }
    customWords.add(word);
    selectedKeys.add(selectionKey(customCategory, word));
    customInput.clear();
    HapticFeedback.selectionClick();
  }
  void grabFromJar() {
    if (releasePhase.value != ReleasePhase.idle) return;
    final pool = <WordPick>[];
    for (final cat in categories) {
      for (final word in cat.words) {
        if (!isSelected(cat.name, word)) {
          pool.add(WordPick(cat.name, word));
        }
      }
    }
    for (final word in customWords) {
      if (!isSelected(customCategory, word)) {
        pool.add(WordPick(customCategory, word));
      }
    }
    if (pool.isEmpty) {
      errorToast('The jar is empty.');
      return;
    }
    final pick = pool[Random().nextInt(pool.length)];
    toggleWord(pick.category, pick.word);
    successToast('Drawn: ${pick.word}');
  }
  void toggleCategory(String name) {
    if (releasePhase.value != ReleasePhase.idle) return;
    WordCategory? cat;
    for (final item in categories) {
      if (item.name == name) {
        cat = item;
        break;
      }
    }
    if (cat == null) return;
    final allOn = cat.words.every((w) => isSelected(name, w));
    for (final word in cat.words) {
      final key = selectionKey(name, word);
      if (allOn) {
        selectedKeys.remove(key);
      } else {
        selectedKeys.add(key);
      }
    }
    HapticFeedback.mediumImpact();
    successToast(allOn ? 'Cleared $name' : 'Poured $name');
  }
  @override
  bool get showDrawAgain => true;
  @override
  String get againLabel => 'Pick another';
  @override
  bool get jarShare => true;
  @override
  void drawAgain() {
    _shredding = false;
    resetRelease();
  }
  void onDiscardTap() {
    if (releasePhase.value == ReleasePhase.done) {
      goHome();
      return;
    }
    if (releasePhase.value == ReleasePhase.shredding) return;
    if (selectedKeys.isEmpty) {
      Get.back();
      return;
    }
    ConfettiDiscardDialog.show(
      title: 'Discard your words?',
      content: 'All selected words will be cleared.',
      onDiscard: Get.back,
    );
  }
  Future<void> shred() async {
    if (selectedKeys.isEmpty) {
      errorToast('Pick words first.');
      return;
    }
    if (_shredding || releasePhase.value != ReleasePhase.idle) return;
    _shredding = true;
    FocusManager.instance.primaryFocus?.unfocus();
    final weight = inkWeight;
    final words = selectedWordLabels;
    selectedKeys.clear();
    customInput.clear();
    await playRelease(inkWeight: weight, words: words, source: 'wordJar');
  }
  @override
  void onClose() {
    customInput.dispose();
    super.onClose();
  }
}
