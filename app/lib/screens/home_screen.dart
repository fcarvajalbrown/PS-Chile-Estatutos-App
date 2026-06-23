import 'package:flutter/material.dart';
import '../repository.dart';
import '../theme.dart';
import 'reader_screen.dart';
import 'quiz_setup_screen.dart';
import 'esquemas_screen.dart';
import 'progreso_screen.dart';
import 'acerca_screen.dart';

class HomeScreen extends StatefulWidget {
  final Repository repo;
  const HomeScreen({super.key, required this.repo});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Repository get repo => widget.repo;

  Future<void> _open(WidgetBuilder builder) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: builder));
    if (mounted) setState(() {}); // refresh stats/progress on return
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _Header(repo: repo),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 16),
                children: [
                  _StatsStrip(
                    repo: repo,
                    onTap: () => _open((_) => ProgresoScreen(repo: repo)),
                  ),
                  _ActionCard(
                    icon: Icons.menu_book_rounded,
                    title: 'Leer los Estatutos',
                    subtitle:
                        'Navega por Título y Artículo. Texto íntegro y oficial.',
                    onTap: () => _open((_) => ReaderScreen(repo: repo)),
                  ),
                  _ActionCard(
                    icon: Icons.school_rounded,
                    title: 'Curso (Quiz)',
                    subtitle:
                        'Pon a prueba lo aprendido, Título por Título o todo el Estatuto.',
                    onTap: () => _open((_) => QuizSetupScreen(repo: repo)),
                  ),
                  _ActionCard(
                    icon: Icons.account_tree_rounded,
                    title: 'Esquemas',
                    subtitle:
                        'Estructura del Partido, datos clave y procedimientos en imágenes.',
                    onTap: () => _open((_) => const EsquemasScreen()),
                  ),
                  const SizedBox(height: 8),
                  const _SourceNote(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final Repository repo;
  const _Header({required this.repo});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [PSColors.red, PSColors.redDark],
            ),
          ),
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
          child: Column(
            children: [
              _EmblemMedallion(),
              const SizedBox(height: 16),
              const Text(
                'Estatutos Nacionales',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Partido Socialista de Chile',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.92),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Fundado el 19 de abril de 1933',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: SafeArea(
            child: IconButton(
              icon: const Icon(Icons.info_outline, color: Colors.white),
              tooltip: 'Acerca de',
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => AcercaScreen(repo: repo)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _EmblemMedallion extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      height: 150,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: PSColors.paper,
        shape: BoxShape.circle,
      ),
      child: Image.asset('assets/img/ps_emblem.png'),
    );
  }
}

/// Compact streak + XP strip; tap to open the progress screen.
class _StatsStrip extends StatelessWidget {
  final Repository repo;
  final VoidCallback onTap;
  const _StatsStrip({required this.repo, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<int>>(
      future: Future.wait([repo.getStreak(), repo.getXp()]),
      builder: (context, snap) {
        final streak = snap.data?[0] ?? 0;
        final xp = snap.data?[1] ?? 0;
        return Card(
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              child: Row(
                children: [
                  const Icon(Icons.local_fire_department_rounded,
                      color: PSColors.red),
                  const SizedBox(width: 6),
                  Text('$streak',
                      style: const TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 18)),
                  Text(' día${streak == 1 ? "" : "s"}',
                      style: const TextStyle(color: PSColors.inkSoft)),
                  const SizedBox(width: 20),
                  const Icon(Icons.bolt_rounded, color: PSColors.gold),
                  const SizedBox(width: 4),
                  Text('$xp',
                      style: const TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 18)),
                  const Text(' XP', style: TextStyle(color: PSColors.inkSoft)),
                  const Spacer(),
                  const Text('Mi progreso',
                      style: TextStyle(
                          color: PSColors.red, fontWeight: FontWeight.w700)),
                  const Icon(Icons.chevron_right, color: PSColors.red),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: PSColors.red.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: PSColors.red, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13.5,
                        color: PSColors.inkSoft,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: PSColors.inkSoft),
            ],
          ),
        ),
      ),
    );
  }
}

class _SourceNote extends StatelessWidget {
  const _SourceNote();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Text(
        'Texto según pschile.cl (actualizado 2026-05-19). App de estudio sin fines de lucro.',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 11.5, color: PSColors.inkSoft),
      ),
    );
  }
}
