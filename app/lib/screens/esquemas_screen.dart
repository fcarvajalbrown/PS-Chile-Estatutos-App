import 'package:flutter/material.dart';
import '../models.dart';
import '../theme.dart';
import '../widgets/fact_box.dart';

/// Visual overview of the party: structure (org chart), key numbers, the
/// disciplinary procedure (Art. 56) and electoral facts. All figures come from
/// the statute; see the article reference on each block.
class EsquemasScreen extends StatelessWidget {
  const EsquemasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Esquemas')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        children: [
          const _SectionTitle('Estructura del Partido', 'Arts. 10–20, 26, 50'),
          const _OrgChart(),
          const SizedBox(height: 24),
          const _SectionTitle('Datos clave de los órganos', 'Arts. 16–20, 51, 60'),
          const FactBoxWidget(
            box: FactBox(articleId: '', title: 'Composición', rows: [
              ('Comité Central', '110 (80 reg. + 30 nac.)'),
              ('Mesa Ejecutiva', '12'),
              ('Comisión Política', '26'),
              ('Tribunal Supremo', '9 titulares + 3 suplentes'),
              ('Tribunales Regionales', '7 (5 titulares + 2 suplentes)'),
            ]),
          ),
          const SizedBox(height: 24),
          const _SectionTitle('Procedimiento disciplinario', 'Art. 56'),
          const _FlowSteps(steps: [
            'Denuncia fundada y por escrito ante el Tribunal competente.',
            'Admisibilidad: debe ser seria, plausible y con mérito suficiente.',
            'Formulación de cargos, notificada al presunto infractor.',
            'Traslado: 10 días para contestar.',
            'Término de prueba: 8 días (ampliable hasta 8 días más).',
            'Resolución fundada en 10 días: absuelve o sanciona.',
            'Reclamación ante el Tribunal Supremo (5 días); falla en 30 días.',
          ]),
          const SizedBox(height: 24),
          const _SectionTitle('Sistema electoral', 'Arts. 39–41'),
          const FactBoxWidget(
            box: FactBox(articleId: '', title: 'Reglas', rows: [
              ('Elecciones', 'cada 24 meses (abril–mayo)'),
              ('Paridad de género', 'ningún sexo > 50%'),
              ('Acción positiva joven', '20% (menores de 30)'),
              ('Antigüedad', '5 años CC · 3 reg./prov. · 1 comunal'),
              ('Reelección', 'máx. 2 períodos consecutivos'),
            ]),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String ref;
  const _SectionTitle(this.title, this.ref);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: PSColors.redDark,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: PSColors.red.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              ref,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: PSColors.redDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrgChart extends StatelessWidget {
  const _OrgChart();

  @override
  Widget build(BuildContext context) {
    const levels = [
      ('Núcleo', 'Organismo de base'),
      ('Comuna', 'Comité Comunal (máxima autoridad) y Dirección Comunal'),
      ('Provincia', 'Dirección Provincial'),
      ('Región', 'Comité Regional → Dirección Regional'),
      ('Nacional', 'Comité Central (110) → Mesa Ejecutiva (12) y Comisión Política (26)'),
      ('Congreso General', 'Organismo político superior (cada 3 años)'),
    ];
    return Column(
      children: [
        for (int i = 0; i < levels.length; i++) ...[
          _LevelCard(level: levels[i].$1, detail: levels[i].$2, top: i == levels.length - 1),
          if (i < levels.length - 1)
            const Icon(Icons.arrow_downward, color: PSColors.red, size: 22),
        ],
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: PSColors.ink.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: PSColors.ink.withValues(alpha: 0.15)),
          ),
          child: const Row(
            children: [
              Icon(Icons.gavel, color: PSColors.ink, size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Tribunal Supremo y Tribunales Regionales: órganos '
                  'jurisdiccionales, independientes de los órganos políticos.',
                  style: TextStyle(fontSize: 13.5, height: 1.4),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LevelCard extends StatelessWidget {
  final String level;
  final String detail;
  final bool top;
  const _LevelCard(
      {required this.level, required this.detail, this.top = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: top ? PSColors.red : PSColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: PSColors.red, width: top ? 0 : 1.4),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 1)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            level,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 15,
              color: top ? Colors.white : PSColors.redDark,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            detail,
            style: TextStyle(
              fontSize: 13,
              height: 1.35,
              color: top ? Colors.white : PSColors.inkSoft,
            ),
          ),
        ],
      ),
    );
  }
}

class _FlowSteps extends StatelessWidget {
  final List<String> steps;
  const _FlowSteps({required this.steps});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < steps.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 26,
                  height: 26,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: PSColors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${i + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Text(
                      steps[i],
                      style: const TextStyle(fontSize: 14.5, height: 1.4),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
