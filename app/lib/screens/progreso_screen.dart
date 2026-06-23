import 'package:flutter/material.dart';
import '../badges.dart';
import '../models.dart';
import '../repository.dart';
import '../theme.dart';
import 'reader_screen.dart';

/// "Mi progreso" — streak, XP, badges and per-Título reading progress.
class ProgresoScreen extends StatefulWidget {
  final Repository repo;
  const ProgresoScreen({super.key, required this.repo});

  @override
  State<ProgresoScreen> createState() => _ProgresoScreenState();
}

class _ProgresoScreenState extends State<ProgresoScreen> {
  late Future<_ProgData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_ProgData> _load() async {
    final est = await widget.repo.loadEstatuto();
    final read = await widget.repo.readArticles();
    final streak = await widget.repo.getStreak();
    final xp = await widget.repo.getXp();
    final unlocked = await widget.repo.badges();
    return _ProgData(est, read, streak, xp, unlocked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mi progreso')),
      body: FutureBuilder<_ProgData>(
        future: _future,
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final d = snap.data!;
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
            children: [
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: Icons.local_fire_department_rounded,
                      color: PSColors.red,
                      value: '${d.streak}',
                      label: d.streak == 1 ? 'día de racha' : 'días de racha',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.bolt_rounded,
                      color: PSColors.gold,
                      value: '${d.xp}',
                      label: 'XP acumulada',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text('Logros',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: PSColors.redDark)),
              const SizedBox(height: 12),
              ...kBadges.map((b) => _BadgeRow(
                    badge: b,
                    unlocked: d.unlocked.contains(b.id),
                  )),
              const SizedBox(height: 24),
              const Text('Lectura por Título',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: PSColors.redDark)),
              const SizedBox(height: 8),
              ...d.estatuto.titulos.map((t) {
                final total = t.articulos.length;
                final done = t.articulos
                    .where((a) => d.read.contains(articleId(t, a)))
                    .length;
                return _TituloProgress(
                  label: t.roman.isEmpty ? 'D.T.' : t.roman,
                  title: t.prettyHeading,
                  done: done,
                  total: total,
                );
              }),
            ],
          );
        },
      ),
    );
  }
}

class _ProgData {
  final Estatuto estatuto;
  final Set<String> read;
  final int streak;
  final int xp;
  final Set<String> unlocked;
  _ProgData(this.estatuto, this.read, this.streak, this.xp, this.unlocked);
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value;
  final String label;
  const _StatCard(
      {required this.icon,
      required this.color,
      required this.value,
      required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: PSColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 6),
          Text(value,
              style:
                  const TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
          Text(label,
              style: const TextStyle(fontSize: 12.5, color: PSColors.inkSoft)),
        ],
      ),
    );
  }
}

class _BadgeRow extends StatelessWidget {
  final Logro badge;
  final bool unlocked;
  const _BadgeRow({required this.badge, required this.unlocked});

  @override
  Widget build(BuildContext context) {
    final color = unlocked ? PSColors.red : PSColors.inkSoft;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: unlocked ? PSColors.red.withValues(alpha: 0.06) : PSColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: unlocked
                ? PSColors.red.withValues(alpha: 0.3)
                : Colors.black12),
      ),
      child: Row(
        children: [
          Opacity(
            opacity: unlocked ? 1 : 0.4,
            child: Icon(badge.icon, color: color, size: 30),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(badge.title,
                    style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: unlocked ? PSColors.ink : PSColors.inkSoft)),
                Text(badge.desc,
                    style: const TextStyle(
                        fontSize: 13, color: PSColors.inkSoft)),
              ],
            ),
          ),
          Icon(unlocked ? Icons.check_circle : Icons.lock_outline,
              color: unlocked ? PSColors.correct : PSColors.inkSoft, size: 20),
        ],
      ),
    );
  }
}

class _TituloProgress extends StatelessWidget {
  final String label;
  final String title;
  final int done;
  final int total;
  const _TituloProgress(
      {required this.label,
      required this.title,
      required this.done,
      required this.total});

  @override
  Widget build(BuildContext context) {
    final pct = total == 0 ? 0.0 : done / total;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          SizedBox(
            width: 34,
            child: Text(label,
                style: const TextStyle(
                    fontWeight: FontWeight.w800, color: PSColors.redDark)),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13.5)),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: pct,
                    minHeight: 7,
                    backgroundColor: Colors.black12,
                    color: pct == 1 ? PSColors.correct : PSColors.red,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text('$done/$total',
              style: const TextStyle(
                  fontSize: 12.5, color: PSColors.inkSoft)),
        ],
      ),
    );
  }
}
