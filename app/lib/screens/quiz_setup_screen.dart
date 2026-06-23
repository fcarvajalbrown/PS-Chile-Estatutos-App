import 'package:flutter/material.dart';
import '../models.dart';
import '../repository.dart';
import '../theme.dart';
import 'quiz_screen.dart';

/// Pick a difficulty tier and a scope (whole statute or a single Título), or
/// review previously-missed questions. Sessions are short (~10 questions).
class QuizSetupScreen extends StatefulWidget {
  final Repository repo;
  const QuizSetupScreen({super.key, required this.repo});

  @override
  State<QuizSetupScreen> createState() => _QuizSetupScreenState();
}

const int kSessionSize = 10;

class _QuizSetupScreenState extends State<QuizSetupScreen> {
  Tier _tier = Tier.basico;
  late Future<_SetupData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_SetupData> _load() async {
    final est = await widget.repo.loadEstatuto();
    final all = await widget.repo.loadQuestions();
    final missed = await widget.repo.missedIds();
    final counts = <String, int>{};
    for (final q in all) {
      if (q.difficulty <= _tier.level) {
        counts[q.titulo] = (counts[q.titulo] ?? 0) + 1;
      }
    }
    final total = all.where((q) => q.difficulty <= _tier.level).length;
    final scores = <String, int>{
      'ALL': await widget.repo.bestScore('ALL_${_tier.level}'),
    };
    for (final roman in counts.keys) {
      scores[roman] = await widget.repo.bestScore('${roman}_${_tier.level}');
    }
    return _SetupData(est, total, counts, scores, missed.length);
  }

  void _setTier(Tier t) => setState(() {
        _tier = t;
        _future = _load();
      });

  Future<void> _start(String? filterRoman, String scopeBase, String label) async {
    final questions =
        await widget.repo.questionsFor(filterRoman, maxDifficulty: _tier.level);
    if (!mounted || questions.isEmpty) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => QuizScreen(
          repo: widget.repo,
          questions: questions,
          scopeKey: '${scopeBase}_${_tier.level}',
          scopeLabel: '$label · ${_tier.label}',
          sessionSize: kSessionSize,
        ),
      ),
    );
    setState(() => _future = _load());
  }

  Future<void> _startReview() async {
    final questions = await widget.repo.missedQuestions();
    if (!mounted || questions.isEmpty) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => QuizScreen(
          repo: widget.repo,
          questions: questions,
          scopeKey: 'REVIEW',
          scopeLabel: 'Repasar los fallados',
          sessionSize: kSessionSize,
          reviewMode: true,
        ),
      ),
    );
    setState(() => _future = _load());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Curso · Quiz')),
      body: FutureBuilder<_SetupData>(
        future: _future,
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snap.data!;
          final titulos = data.estatuto.titulos
              .where((t) => (data.byTitulo[t.roman] ?? 0) > 0)
              .toList();
          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 12),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                child: SegmentedButton<Tier>(
                  segments: const [
                    ButtonSegment(value: Tier.basico, label: Text('Básico')),
                    ButtonSegment(
                        value: Tier.intermedio, label: Text('Intermedio')),
                    ButtonSegment(value: Tier.avanzado, label: Text('Avanzado')),
                  ],
                  selected: {_tier},
                  onSelectionChanged: (s) => _setTier(s.first),
                  style: ButtonStyle(
                    visualDensity: VisualDensity.compact,
                    backgroundColor: WidgetStateProperty.resolveWith(
                      (s) => s.contains(WidgetState.selected)
                          ? PSColors.red
                          : null,
                    ),
                    foregroundColor: WidgetStateProperty.resolveWith(
                      (s) => s.contains(WidgetState.selected)
                          ? Colors.white
                          : PSColors.ink,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                child: Text(
                  _tierHint(_tier),
                  style: const TextStyle(fontSize: 12.5, color: PSColors.inkSoft),
                ),
              ),
              if (data.missed > 0)
                _QuizOption(
                  badge: '↺',
                  title: 'Repasar los fallados',
                  subtitle:
                      '${data.missed} pregunta${data.missed == 1 ? "" : "s"} que erraste',
                  best: 0,
                  onTap: _startReview,
                ),
              _QuizOption(
                badge: 'TODO',
                title: 'Todo el Estatuto',
                subtitle: _scopeSubtitle(data.total),
                best: data.scores['ALL'] ?? 0,
                emphasized: true,
                onTap: () => _start(null, 'ALL', 'Todo el Estatuto'),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 12, 20, 4),
                child: Text('Por Título',
                    style: TextStyle(
                        fontWeight: FontWeight.w700, color: PSColors.inkSoft)),
              ),
              ...titulos.map((t) {
                final n = data.byTitulo[t.roman] ?? 0;
                return _QuizOption(
                  badge: t.roman,
                  title: t.prettyHeading,
                  subtitle: _scopeSubtitle(n),
                  best: data.scores[t.roman] ?? 0,
                  onTap: () => _start(t.roman, t.roman, 'Título ${t.roman}'),
                );
              }),
            ],
          );
        },
      ),
    );
  }

  String _scopeSubtitle(int pool) {
    if (pool <= kSessionSize) {
      return '$pool pregunta${pool == 1 ? "" : "s"}';
    }
    return '$kSessionSize preguntas al azar de $pool';
  }

  String _tierHint(Tier t) {
    switch (t) {
      case Tier.basico:
        return 'Básico: lo esencial, ideal para empezar.';
      case Tier.intermedio:
        return 'Intermedio: suma reglas y composiciones de los órganos.';
      case Tier.avanzado:
        return 'Avanzado: plazos, quórums y detalles finos.';
    }
  }
}

class _SetupData {
  final Estatuto estatuto;
  final int total;
  final Map<String, int> byTitulo;
  final Map<String, int> scores;
  final int missed;
  _SetupData(
      this.estatuto, this.total, this.byTitulo, this.scores, this.missed);
}

class _QuizOption extends StatelessWidget {
  final String badge;
  final String title;
  final String subtitle;
  final int best;
  final bool emphasized;
  final VoidCallback onTap;
  const _QuizOption({
    required this.badge,
    required this.title,
    required this.subtitle,
    required this.best,
    required this.onTap,
    this.emphasized = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: emphasized ? PSColors.red : PSColors.surface,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: emphasized
                      ? Colors.white.withValues(alpha: 0.2)
                      : PSColors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: emphasized ? Colors.white : PSColors.ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: emphasized
                            ? Colors.white.withValues(alpha: 0.9)
                            : PSColors.inkSoft,
                      ),
                    ),
                  ],
                ),
              ),
              if (best > 0)
                _ScorePill(best: best, light: emphasized)
              else
                Icon(Icons.chevron_right,
                    color: emphasized ? Colors.white : PSColors.inkSoft),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScorePill extends StatelessWidget {
  final int best;
  final bool light;
  const _ScorePill({required this.best, required this.light});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: light
            ? Colors.white.withValues(alpha: 0.2)
            : PSColors.gold.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded,
              size: 16, color: light ? Colors.white : PSColors.gold),
          const SizedBox(width: 3),
          Text(
            '$best%',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 13,
              color: light ? Colors.white : PSColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}
