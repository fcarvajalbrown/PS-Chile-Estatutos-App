import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../repository.dart';
import '../theme.dart';

/// "Acerca de" — purpose, source of the content, credits, and a reset for the
/// user's local progress. Also home of the Salvador Allende illustration.
class AcercaScreen extends StatelessWidget {
  final Repository repo;
  const AcercaScreen({super.key, required this.repo});

  Future<void> _confirmReset(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reiniciar progreso'),
        content: const Text(
            'Se borrarán los artículos leídos y los puntajes del quiz. '
            'Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Reiniciar'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await repo.resetProgress();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Progreso reiniciado.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Acerca de')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        children: [
          Center(
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: PSColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: PSColors.red.withValues(alpha: 0.25)),
              ),
              child: SvgPicture.asset(
                'assets/img/allende_outline.svg',
                height: 240,
                colorFilter: const ColorFilter.mode(
                  PSColors.ink,
                  BlendMode.srcIn,
                ),
                semanticsLabel: 'Salvador Allende',
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Center(
            child: Text(
              'Salvador Allende Gossens',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
          ),
          const Center(
            child: Text(
              'Presidente de Chile · 1970–1973',
              style: TextStyle(color: PSColors.inkSoft),
            ),
          ),
          const SizedBox(height: 28),
          const _Section(
            title: 'Qué es esta app',
            body:
                'Una herramienta de formación para estudiar los Estatutos '
                'Nacionales del Partido Socialista de Chile: leerlos por Título '
                'y Artículo, y poner a prueba lo aprendido con el curso tipo quiz.',
          ),
          const _Section(
            title: 'Fuente del contenido',
            body:
                'El texto de los Estatutos es íntegro y se basa en la versión '
                'publicada en pschile.cl (actualizada el 19 de mayo de 2026). '
                'Cada respuesta del quiz se apoya en el artículo que la respalda.',
          ),
          const _Section(
            title: 'Desarrollo',
            body: 'Felipe Carvajal Brown · Comunal Ñuñoa.',
          ),
          const _Section(
            title: 'Créditos',
            body:
                'Emblema institucional del Partido Socialista de Chile. '
                'Ilustración de Salvador Allende: contorno vectorial de Wikimedia '
                'Commons (Salvador Allende 1973, SVG Outline).',
          ),
          const SizedBox(height: 8),
          const Center(
            child: Text(
              'Partido Socialista de Chile · fundado el 19 de abril de 1933',
              style: TextStyle(
                color: PSColors.red,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 28),
          Center(
            child: OutlinedButton.icon(
              onPressed: () => _confirmReset(context),
              icon: const Icon(Icons.restart_alt),
              label: const Text('Reiniciar progreso'),
              style: OutlinedButton.styleFrom(
                foregroundColor: PSColors.red,
                side: const BorderSide(color: PSColors.red),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final String body;
  const _Section({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: PSColors.redDark,
            ),
          ),
          const SizedBox(height: 6),
          Text(body, style: const TextStyle(fontSize: 15, height: 1.5)),
        ],
      ),
    );
  }
}
