/// Data models for the statute content and the quiz.
///
/// Content models mirror the shape produced by tools/parse_estatutos.ps1 and
/// shipped in assets/data/estatutos.json. Do not hand-edit that JSON; fix the
/// source text and regenerate.
library;

class Estatuto {
  final String title;
  final String source;
  final String updated;
  final List<Titulo> titulos;

  Estatuto({
    required this.title,
    required this.source,
    required this.updated,
    required this.titulos,
  });

  factory Estatuto.fromJson(Map<String, dynamic> json) => Estatuto(
        title: json['title'] as String? ?? '',
        source: json['source'] as String? ?? '',
        updated: json['updated'] as String? ?? '',
        titulos: (json['titles'] as List<dynamic>)
            .map((e) => Titulo.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class Titulo {
  final String roman; // "I", "II", ... or "" for the transitorias block
  final String heading;
  final List<Articulo> articulos;

  Titulo({required this.roman, required this.heading, required this.articulos});

  factory Titulo.fromJson(Map<String, dynamic> json) => Titulo(
        roman: json['roman'] as String? ?? '',
        heading: json['heading'] as String? ?? '',
        articulos: (json['articles'] as List<dynamic>)
            .map((e) => Articulo.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  /// Display label such as "Título IV" or "Disposiciones Transitorias".
  String get label => roman.isEmpty ? heading : 'Título $roman';

  /// Heading shown in title case (source is ALL CAPS with a trailing period).
  String get prettyHeading {
    final t = heading.replaceAll(RegExp(r'\.$'), '').trim();
    if (roman.isEmpty) return t;
    return _toTitleCase(t);
  }
}

class Articulo {
  final String number; // "1", "19 bis", "final", "primero", ...
  final String heading; // optional sub-heading, e.g. "Del Núcleo"
  final List<String> paragraphs;

  Articulo({
    required this.number,
    required this.heading,
    required this.paragraphs,
  });

  factory Articulo.fromJson(Map<String, dynamic> json) => Articulo(
        number: json['number'] as String? ?? '',
        heading: json['heading'] as String? ?? '',
        paragraphs: (json['paragraphs'] as List<dynamic>)
            .map((e) => e as String)
            .toList(),
      );

  String get label {
    final n = number.toLowerCase();
    if (n == 'final') return 'Artículo final';
    if (RegExp(r'^[a-z]').hasMatch(n)) return 'Artículo $number'; // primero/segundo
    return 'Artículo $number';
  }
}

class QuizQuestion {
  final String titulo; // roman numeral this question belongs to
  final String question;
  final List<String> options;
  final int correct; // index into options
  final String articleRef; // e.g. "Art. 17" — proof of the answer
  final String explanation;
  final int difficulty; // 1 = Básico, 2 = Intermedio, 3 = Avanzado

  QuizQuestion({
    required this.titulo,
    required this.question,
    required this.options,
    required this.correct,
    required this.articleRef,
    required this.explanation,
    this.difficulty = 1,
  });

  /// Stable identifier for progress tracking (e.g. missed questions).
  String get id => '$titulo|$articleRef|$question';

  factory QuizQuestion.fromJson(Map<String, dynamic> json) => QuizQuestion(
        titulo: json['titulo'] as String? ?? '',
        question: json['question'] as String,
        options: (json['options'] as List<dynamic>)
            .map((e) => e as String)
            .toList(),
        correct: json['correct'] as int,
        articleRef: json['articleRef'] as String? ?? '',
        explanation: json['explanation'] as String? ?? '',
        difficulty: json['difficulty'] as int? ?? 1,
      );
}

/// A "For Dummies"-style aside attached to an article in the reader.
enum CalloutType {
  sabias('¿Sabías que?'),
  practica('En la práctica'),
  ojo('Ojo'),
  recuerda('Recuerda');

  const CalloutType(this.label);
  final String label;

  static CalloutType parse(String s) {
    switch (s) {
      case 'practica':
        return CalloutType.practica;
      case 'ojo':
        return CalloutType.ojo;
      case 'recuerda':
        return CalloutType.recuerda;
      case 'sabias':
      default:
        return CalloutType.sabias;
    }
  }
}

class Callout {
  final String articleId; // "<roman>#<number>", matches reader's articleId()
  final CalloutType type;
  final String text;

  Callout({required this.articleId, required this.type, required this.text});

  factory Callout.fromJson(Map<String, dynamic> json) => Callout(
        articleId: json['id'] as String,
        type: CalloutType.parse(json['type'] as String? ?? 'sabias'),
        text: json['text'] as String,
      );
}

/// A "Datos clave" table attached to an article (numbers, quórums, sizes).
class FactBox {
  final String articleId;
  final String title;
  final List<(String, String)> rows; // (label, value)

  const FactBox(
      {required this.articleId, required this.title, required this.rows});

  factory FactBox.fromJson(Map<String, dynamic> json) => FactBox(
        articleId: json['id'] as String,
        title: json['title'] as String,
        rows: (json['rows'] as List<dynamic>).map((r) {
          final pair = r as List<dynamic>;
          return (pair[0] as String, pair[1] as String);
        }).toList(),
      );
}

/// The three difficulty tiers used by the quiz.
enum Tier {
  basico(1, 'Básico'),
  intermedio(2, 'Intermedio'),
  avanzado(3, 'Avanzado');

  const Tier(this.level, this.label);
  final int level; // questions with difficulty <= level are included
  final String label;
}

String _toTitleCase(String input) {
  const lower = {
    'de', 'del', 'la', 'el', 'los', 'las', 'y', 'en', 'e', 'o', 'u', 'a'
  };
  final words = input.toLowerCase().split(RegExp(r'\s+'));
  return words.asMap().entries.map((entry) {
    final i = entry.key;
    final w = entry.value;
    if (w.isEmpty) return w;
    if (i != 0 && lower.contains(w)) return w;
    return w[0].toUpperCase() + w.substring(1);
  }).join(' ');
}
