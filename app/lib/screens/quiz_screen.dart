import 'dart:math';
import 'package:flutter/material.dart';
import '../models.dart';
import '../repository.dart';
import '../theme.dart';

class QuizScreen extends StatefulWidget {
  final Repository repo;
  final List<QuizQuestion> questions;
  final String scopeKey; // "ALL" or a Título roman numeral (incl. tier)
  final String scopeLabel;
  final int sessionSize; // max questions per round
  final bool reviewMode; // "repasar los fallados": clears missed on correct
  const QuizScreen({
    super.key,
    required this.repo,
    required this.questions,
    required this.scopeKey,
    required this.scopeLabel,
    this.sessionSize = 10,
    this.reviewMode = false,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

/// A question with its options shuffled for presentation, so the correct answer
/// is not always in the same position. [correct] is the index into the shuffled
/// [options].
class _PreparedQuestion {
  final String id;
  final String question;
  final List<String> options;
  final int correct;
  final String articleRef;
  final String explanation;
  _PreparedQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correct,
    required this.articleRef,
    required this.explanation,
  });

  factory _PreparedQuestion.from(QuizQuestion q, Random rng) {
    final order = List<int>.generate(q.options.length, (i) => i)..shuffle(rng);
    return _PreparedQuestion(
      id: q.id,
      question: q.question,
      options: [for (final i in order) q.options[i]],
      correct: order.indexOf(q.correct),
      articleRef: q.articleRef,
      explanation: q.explanation,
    );
  }
}

class _QuizScreenState extends State<QuizScreen> {
  final Random _rng = Random();
  late List<_PreparedQuestion> _questions;
  int _index = 0;
  int? _selected;
  int _correctCount = 0;
  bool _finished = false;
  int _best = 0;

  @override
  void initState() {
    super.initState();
    _questions = _prepare();
  }

  List<_PreparedQuestion> _prepare() {
    final shuffled = [...widget.questions]..shuffle(_rng);
    final take = shuffled.take(widget.sessionSize).toList();
    return [for (final q in take) _PreparedQuestion.from(q, _rng)];
  }

  _PreparedQuestion get _q => _questions[_index];
  bool get _answered => _selected != null;

  void _select(int i) {
    if (_answered) return;
    setState(() {
      _selected = i;
      if (i == _q.correct) {
        _correctCount++;
        if (widget.reviewMode) widget.repo.removeMissed(_q.id);
      } else {
        widget.repo.addMissed(_q.id);
      }
    });
  }

  Future<void> _next() async {
    if (_index + 1 < _questions.length) {
      setState(() {
        _index++;
        _selected = null;
      });
    } else {
      final pct = ((_correctCount / _questions.length) * 100).round();
      await widget.repo.addXp(_correctCount * 10);
      final streak = await widget.repo.registerActivityToday(DateTime.now());
      await widget.repo.unlockBadge('first_quiz');
      if (pct == 100) await widget.repo.unlockBadge('perfect');
      if (streak >= 3) await widget.repo.unlockBadge('streak3');
      if (streak >= 7) await widget.repo.unlockBadge('streak7');
      final best = await widget.repo.saveScore(widget.scopeKey, pct);
      if (mounted) {
        setState(() {
          _finished = true;
          _best = best;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.scopeLabel),
        bottom: _finished
            ? null
            : PreferredSize(
                preferredSize: const Size.fromHeight(4),
                child: LinearProgressIndicator(
                  value: (_index + (_answered ? 1 : 0)) / _questions.length,
                  backgroundColor: PSColors.redDark,
                  color: Colors.white,
                  minHeight: 4,
                ),
              ),
      ),
      body: _finished ? _buildResults() : _buildQuestion(),
    );
  }

  Widget _buildQuestion() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      children: [
        Text(
          'Pregunta ${_index + 1} de ${_questions.length}',
          style: const TextStyle(
            color: PSColors.inkSoft,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          _q.question,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 20),
        ...List.generate(_q.options.length, (i) => _option(i)),
        if (_answered) _feedback(),
        if (_answered) ...[
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _next,
            child: Text(
              _index + 1 < _questions.length ? 'Siguiente' : 'Ver resultado',
            ),
          ),
        ],
      ],
    );
  }

  Widget _option(int i) {
    final isCorrect = i == _q.correct;
    final isSelected = i == _selected;
    Color border = Colors.black12;
    Color bg = PSColors.surface;
    Widget? trailing;

    if (_answered) {
      if (isCorrect) {
        border = PSColors.correct;
        bg = PSColors.correct.withValues(alpha: 0.10);
        trailing = const Icon(Icons.check_circle, color: PSColors.correct);
      } else if (isSelected) {
        border = PSColors.wrong;
        bg = PSColors.wrong.withValues(alpha: 0.10);
        trailing = const Icon(Icons.cancel, color: PSColors.wrong);
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _select(i),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: bg,
            border: Border.all(color: border, width: 1.6),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: PSColors.paper,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  String.fromCharCode(65 + i), // A, B, C...
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _q.options[i],
                  style: const TextStyle(fontSize: 15.5, height: 1.3),
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
        ),
      ),
    );
  }

  Widget _feedback() {
    final right = _selected == _q.correct;
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: (right ? PSColors.correct : PSColors.wrong)
            .withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (right ? PSColors.correct : PSColors.wrong)
              .withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(right ? Icons.check_circle : Icons.info,
                  color: right ? PSColors.correct : PSColors.wrong, size: 20),
              const SizedBox(width: 6),
              Text(
                right ? 'Correcto' : 'Respuesta correcta:',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: right ? PSColors.correct : PSColors.wrong,
                ),
              ),
              const Spacer(),
              if (_q.articleRef.isNotEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: PSColors.red,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _q.articleRef,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          if (!right) ...[
            const SizedBox(height: 6),
            Text(
              _q.options[_q.correct],
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
          if (_q.explanation.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(_q.explanation,
                style: const TextStyle(fontSize: 14, height: 1.4)),
          ],
        ],
      ),
    );
  }

  Widget _buildResults() {
    final pct = ((_correctCount / _questions.length) * 100).round();
    final isRecord = pct >= _best && pct > 0;
    String verdict;
    if (pct == 100) {
      verdict = 'Perfecto. Dominas este material.';
    } else if (pct >= 70) {
      verdict = 'Buen trabajo. Vas encaminado(a).';
    } else if (pct >= 40) {
      verdict = 'Vas avanzando. Repasa los artículos citados.';
    } else {
      verdict = 'A repasar. Vuelve a la sección Leer y reinténtalo.';
    }

    return Center(
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.all(28),
        children: [
          Center(
            child: Container(
              width: 140,
              height: 140,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: PSColors.red,
                shape: BoxShape.circle,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$pct%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 38,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    '$_correctCount/${_questions.length}',
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            verdict,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            isRecord
                ? 'Nuevo récord en ${widget.scopeLabel}.'
                : 'Tu mejor marca: $_best%.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: PSColors.inkSoft),
          ),
          const SizedBox(height: 28),
          FilledButton(
            onPressed: () => setState(() {
              _index = 0;
              _selected = null;
              _correctCount = 0;
              _finished = false;
              _questions = _prepare();
            }),
            child: const Text('Reintentar'),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Volver'),
          ),
        ],
      ),
    );
  }
}
