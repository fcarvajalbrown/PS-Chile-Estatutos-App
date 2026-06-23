import 'package:flutter/material.dart';
import '../models.dart';
import '../repository.dart';
import '../theme.dart';
import '../widgets/callout_box.dart';

String articleId(Titulo t, Articulo a) =>
    '${t.roman.isEmpty ? "TRANS" : t.roman}#${a.number}';

/// Lists the Títulos, with how many of each Título's articles have been read.
class ReaderScreen extends StatefulWidget {
  final Repository repo;
  const ReaderScreen({super.key, required this.repo});

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  late Future<_ReaderData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_ReaderData> _load() async {
    final est = await widget.repo.loadEstatuto();
    final read = await widget.repo.readArticles();
    return _ReaderData(est, read);
  }

  void _refresh() => setState(() => _future = _load());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Leer los Estatutos')),
      body: FutureBuilder<_ReaderData>(
        future: _future,
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final est = snap.data!.estatuto;
          final read = snap.data!.read;
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: est.titulos.length,
            itemBuilder: (context, i) {
              final t = est.titulos[i];
              final total = t.articulos.length;
              final done =
                  t.articulos.where((a) => read.contains(articleId(t, a))).length;
              return Card(
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  leading: _RomanBadge(t.roman),
                  title: Text(
                    t.prettyHeading,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text('$total artículo${total == 1 ? "" : "s"}  ·  '
                        '$done leído${done == 1 ? "" : "s"}'),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => TituloScreen(repo: widget.repo, titulo: t),
                      ),
                    );
                    _refresh();
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _ReaderData {
  final Estatuto estatuto;
  final Set<String> read;
  _ReaderData(this.estatuto, this.read);
}

class _RomanBadge extends StatelessWidget {
  final String roman;
  const _RomanBadge(this.roman);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: PSColors.red,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        roman.isEmpty ? 'DT' : roman,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 15,
        ),
      ),
    );
  }
}

/// Shows the articles of one Título as expandable cards. Expanding an article
/// marks it as read.
class TituloScreen extends StatefulWidget {
  final Repository repo;
  final Titulo titulo;
  const TituloScreen({super.key, required this.repo, required this.titulo});

  @override
  State<TituloScreen> createState() => _TituloScreenState();
}

class _TituloScreenState extends State<TituloScreen> {
  Set<String> _read = {};
  Map<String, List<Callout>> _callouts = {};

  @override
  void initState() {
    super.initState();
    widget.repo.readArticles().then((r) {
      if (mounted) setState(() => _read = r);
    });
    widget.repo.loadCallouts().then((c) {
      if (mounted) setState(() => _callouts = c);
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.titulo;
    return Scaffold(
      appBar: AppBar(
        title: Text(t.roman.isEmpty ? 'Disposiciones' : 'Título ${t.roman}'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          Text(
            t.prettyHeading,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: PSColors.redDark,
            ),
          ),
          const SizedBox(height: 12),
          ...t.articulos.map((a) {
            final id = articleId(t, a);
            final isRead = _read.contains(id);
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: ExpansionTile(
                shape: const Border(),
                collapsedShape: const Border(),
                tilePadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                leading: Icon(
                  isRead ? Icons.check_circle : Icons.circle_outlined,
                  color: isRead ? PSColors.correct : PSColors.inkSoft,
                ),
                title: Text(
                  a.label,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: a.heading.isEmpty
                    ? null
                    : Text(a.heading,
                        style: const TextStyle(color: PSColors.inkSoft)),
                onExpansionChanged: (open) {
                  if (open && !isRead) {
                    widget.repo.markRead(id);
                    setState(() => _read = {..._read, id});
                  }
                },
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final p in a.paragraphs)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Text(
                              p,
                              style: const TextStyle(
                                fontSize: 15.5,
                                height: 1.5,
                                color: PSColors.ink,
                              ),
                            ),
                          ),
                        for (final c in (_callouts[id] ?? const <Callout>[]))
                          CalloutBox(callout: c),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
