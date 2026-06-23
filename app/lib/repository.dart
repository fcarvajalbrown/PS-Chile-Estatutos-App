import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';

/// Loads bundled content and persists lightweight progress (read articles and
/// best quiz scores). Everything is offline; no network access.
class Repository {
  Estatuto? _estatuto;
  List<QuizQuestion>? _questions;

  Future<Estatuto> loadEstatuto() async {
    if (_estatuto != null) return _estatuto!;
    final raw = await rootBundle.loadString('assets/data/estatutos.json');
    _estatuto = Estatuto.fromJson(json.decode(raw) as Map<String, dynamic>);
    return _estatuto!;
  }

  Map<String, List<Callout>>? _callouts;

  /// Callouts grouped by article id (`roman#number`).
  Future<Map<String, List<Callout>>> loadCallouts() async {
    if (_callouts != null) return _callouts!;
    final raw = await rootBundle.loadString('assets/data/callouts.json');
    final list = (json.decode(raw) as List<dynamic>)
        .map((e) => Callout.fromJson(e as Map<String, dynamic>))
        .toList();
    final map = <String, List<Callout>>{};
    for (final c in list) {
      map.putIfAbsent(c.articleId, () => []).add(c);
    }
    _callouts = map;
    return map;
  }

  Map<String, FactBox>? _factBoxes;

  /// Fact boxes keyed by article id (`roman#number`).
  Future<Map<String, FactBox>> loadFactBoxes() async {
    if (_factBoxes != null) return _factBoxes!;
    final raw = await rootBundle.loadString('assets/data/factboxes.json');
    final list = (json.decode(raw) as List<dynamic>)
        .map((e) => FactBox.fromJson(e as Map<String, dynamic>))
        .toList();
    _factBoxes = {for (final f in list) f.articleId: f};
    return _factBoxes!;
  }

  Future<List<QuizQuestion>> loadQuestions() async {
    if (_questions != null) return _questions!;
    final raw = await rootBundle.loadString('assets/data/quiz.json');
    final list = (json.decode(raw) as List<dynamic>)
        .map((e) => QuizQuestion.fromJson(e as Map<String, dynamic>))
        .toList();
    _questions = list;
    return list;
  }

  /// Questions for one Título (or all if [roman] is null), filtered to the
  /// given tier (questions whose difficulty <= [maxDifficulty]).
  Future<List<QuizQuestion>> questionsFor(String? roman,
      {int maxDifficulty = 3}) async {
    final all = await loadQuestions();
    return all
        .where((q) =>
            (roman == null || q.titulo == roman) &&
            q.difficulty <= maxDifficulty)
        .toList();
  }

  /// How many questions exist per Título at the given tier.
  Future<Map<String, int>> countsByTitulo(int maxDifficulty) async {
    final all = await loadQuestions();
    final counts = <String, int>{};
    for (final q in all) {
      if (q.difficulty <= maxDifficulty) {
        counts[q.titulo] = (counts[q.titulo] ?? 0) + 1;
      }
    }
    return counts;
  }

  // ---- Missed questions ("repasar los fallados") ----

  static const _missedKey = 'missed_questions';

  Future<Set<String>> missedIds() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_missedKey) ?? const <String>[]).toSet();
  }

  Future<void> addMissed(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final set = (prefs.getStringList(_missedKey) ?? <String>[]).toSet();
    set.add(id);
    await prefs.setStringList(_missedKey, set.toList());
  }

  Future<void> removeMissed(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final set = (prefs.getStringList(_missedKey) ?? <String>[]).toSet();
    set.remove(id);
    await prefs.setStringList(_missedKey, set.toList());
  }

  /// The questions the user has previously answered wrong.
  Future<List<QuizQuestion>> missedQuestions() async {
    final all = await loadQuestions();
    final ids = await missedIds();
    return all.where((q) => ids.contains(q.id)).toList();
  }

  /// Clears all stored progress: read articles, quiz best scores, missed
  /// questions, and gamification (streak/XP/badges).
  Future<void> resetProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) =>
        k == _readKey ||
        k == _missedKey ||
        k.startsWith('best_') ||
        k.startsWith('gam_')).toList();
    for (final k in keys) {
      await prefs.remove(k);
    }
  }

  // ---- Progress: read articles ----

  static const _readKey = 'read_articles';

  Future<Set<String>> readArticles() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_readKey) ?? const <String>[]).toSet();
  }

  Future<void> markRead(String articleId) async {
    final prefs = await SharedPreferences.getInstance();
    final set = (prefs.getStringList(_readKey) ?? <String>[]).toSet();
    set.add(articleId);
    await prefs.setStringList(_readKey, set.toList());
  }

  // ---- Progress: best quiz score per Título ("ALL" for the full course) ----

  String _scoreKey(String roman) => 'best_$roman';

  Future<int> bestScore(String roman) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_scoreKey(roman)) ?? 0;
  }

  /// Saves [pct] (0..100) if it beats the previous best. Returns the stored best.
  Future<int> saveScore(String roman, int pct) async {
    final prefs = await SharedPreferences.getInstance();
    final prev = prefs.getInt(_scoreKey(roman)) ?? 0;
    if (pct > prev) {
      await prefs.setInt(_scoreKey(roman), pct);
      return pct;
    }
    return prev;
  }
}
