import 'package:flutter/material.dart';
import '../models.dart';
import '../repository.dart';
import '../theme.dart';
import 'quiz_screen.dart';

/// Lets the user pick the full-statute quiz or a single Título, and shows the
/// best score achieved for each.
class QuizSetupScreen extends StatefulWidget {
  final Repository repo;
  const QuizSetupScreen({super.key, required this.repo});

  @override
  State<QuizSetupScreen> createState() => _QuizSetupScreenState();
}

class _QuizSetupScreenState extends State<QuizSetupScreen> {
  late Future<_SetupData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_SetupData> _load() async {
    final est = await widget.repo.loadEstatuto();
    final qs = await widget.repo.loadQuestions();
    final byTitulo = <String, int>{};
    for (final q in qs) {
      byTitulo[q.titulo] = (byTitulo[q.titulo] ?? 0) + 1;
    }
    final scores = <String, int>{'ALL': await widget.repo.bestScore('ALL')};
    for (final roman in byTitulo.keys) {
      scores[roman] = await widget.repo.bestScore(roman);
    }
    return _SetupData(est, qs.length, byTitulo, scores);
  }

  void _refresh() => setState(() => _future = _load());

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
          final titulosWithQuestions = data.estatuto.titulos
              .where((t) => data.byTitulo.containsKey(t.roman))
              .toList();
          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 12),
            children: [
              _QuizOption(
                badge: 'TODO',
                title: 'Todo el Estatuto',
                subtitle: '${data.total} preguntas de todos los Títulos',
                best: data.scores['ALL'] ?? 0,
                emphasized: true,
                onTap: () => _start(context, null, 'ALL', 'Todo el Estatuto'),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 12, 20, 4),
                child: Text(
                  'Por Título',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: PSColors.inkSoft,
                  ),
                ),
              ),
              ...titulosWithQuestions.map((t) {
                final n = data.byTitulo[t.roman] ?? 0;
                return _QuizOption(
                  badge: t.roman,
                  title: t.prettyHeading,
                  subtitle: '$n pregunta${n == 1 ? "" : "s"}',
                  best: data.scores[t.roman] ?? 0,
                  onTap: () =>
                      _start(context, t.roman, t.roman, 'Título ${t.roman}'),
                );
              }),
            ],
          );
        },
      ),
    );
  }

  Future<void> _start(
      BuildContext context, String? filterRoman, String scopeKey, String label) async {
    final questions = await widget.repo.questionsFor(filterRoman);
    if (!context.mounted || questions.isEmpty) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => QuizScreen(
          repo: widget.repo,
          questions: questions,
          scopeKey: scopeKey,
          scopeLabel: label,
        ),
      ),
    );
    _refresh();
  }
}

class _SetupData {
  final Estatuto estatuto;
  final int total;
  final Map<String, int> byTitulo;
  final Map<String, int> scores;
  _SetupData(this.estatuto, this.total, this.byTitulo, this.scores);
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
