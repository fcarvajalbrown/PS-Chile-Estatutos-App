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

  Future<List<QuizQuestion>> loadQuestions() async {
    if (_questions != null) return _questions!;
    final raw = await rootBundle.loadString('assets/data/quiz.json');
    final list = (json.decode(raw) as List<dynamic>)
        .map((e) => QuizQuestion.fromJson(e as Map<String, dynamic>))
        .toList();
    _questions = list;
    return list;
  }

  /// Questions for one Título, or all if [roman] is null.
  Future<List<QuizQuestion>> questionsFor(String? roman) async {
    final all = await loadQuestions();
    if (roman == null) return all;
    return all.where((q) => q.titulo == roman).toList();
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
