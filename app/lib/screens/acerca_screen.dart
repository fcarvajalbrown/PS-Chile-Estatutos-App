import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme.dart';

/// "Acerca de" — purpose, source of the content, and credits. Home of the
/// Salvador Allende illustration, the party's founder.
class AcercaScreen extends StatelessWidget {
  const AcercaScreen({super.key});

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
