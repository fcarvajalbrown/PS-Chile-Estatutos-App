import 'package:flutter/material.dart';

/// Achievement badge ("logro"). Named Logro to avoid clashing with the Material
/// `Badge` widget. A small, "lite" set — no leagues or leaderboards.
class Logro {
  final String id;
  final String title;
  final String desc;
  final IconData icon;
  const Logro(this.id, this.title, this.desc, this.icon);
}

const List<Logro> kBadges = [
  Logro('first_quiz', 'Primer quiz', 'Completaste tu primer quiz.',
      Icons.flag_rounded),
  Logro('perfect', 'Sin errores', '100% de aciertos en un quiz.',
      Icons.star_rounded),
  Logro('streak3', 'Racha de 3', 'Tres días seguidos estudiando.',
      Icons.local_fire_department_rounded),
  Logro('streak7', 'Racha de 7', 'Una semana seguida estudiando.',
      Icons.whatshot_rounded),
  Logro('reader_titulo', 'Lector/a', 'Leíste un Título completo.',
      Icons.menu_book_rounded),
];
