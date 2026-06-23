# CLAUDE.md — PS Chile Estatutos (Android app)

Project-specific instructions for working in this repository. These inherit and
do not override the user's global rules (no invented facts; offer choices via the
interactive option UI with exactly one "(Recommended)" option and a stated why;
no emojis anywhere).

## What this is

A Flutter Android app that teaches the **Estatutos Nacionales del Partido
Socialista de Chile** two ways:
1. **Leer** — read the statutes by Título / Artículo (reference mode).
2. **Curso** — a quiz that tests knowledge of the real statute text.

Visual identity: Socialist Party of Chile palette (red / black / off-white) and a
stylized, original vector portrait of Salvador Allende (no copyrighted photo).

## Hard rules for this repo (content integrity)

- **Never invent or paraphrase statute content.** Every word a user reads in
  "Leer" must come verbatim from the official source captured in `source/`.
  The content asset `app/assets/data/estatutos.json` is GENERATED from
  `source/estatutos_clean.txt` by `tools/parse_estatutos.ps1` — do not hand-edit
  the JSON. To change content, fix the source text and re-run the parser.
- **Every quiz answer must be verifiable against the statute.** Each question in
  `app/assets/data/quiz.json` carries an `articleRef` (e.g. "Art. 17") pointing to
  the article that proves the correct answer. The `correct` option must match that
  article's text. Distractors are deliberately wrong but plausible; they are the
  only invented strings allowed, and they must never be defensibly "also correct".
- If asked to add questions or sections and the supporting text is not in
  `source/`, stop and ask for the authoritative text rather than inventing it.

## Source of truth

- `source/estatutos.html` — raw page downloaded from https://www.pschile.cl/estatutos/
- `source/estatutos.txt` — full text stripped from the HTML (includes site chrome)
- `source/estatutos_clean.txt` — just the statute body (Título I .. Disposiciones
  Transitorias), the authoritative input for the parser.
- Document version on the official site: **updated 2026-05-19** (15 Títulos,
  Artículos 1–67 + Artículo final + 2 disposiciones transitorias).

## Party facts (reference — do not get these wrong in UI copy)

Source: https://es.wikipedia.org/wiki/Partido_Socialista_de_Chile

- Official name: **Partido Socialista de Chile (PS)**.
- Founded: **19 de abril de 1933**, Calle Serrano 150, Santiago de Chile.
- Founding was the union of four groups (leaders incl. Eugenio Matte Hurtado,
  Óscar Schnake, Eduardo Rodríguez Mazer, Arturo Bianchi Gundian).
  **Salvador Allende was NOT "the founder"** — do not caption him that way. He was
  a militant and **Presidente de Chile (1970–1973)**.
- **There is NO official slogan/lema.** "Democráticos, allendistas y de izquierda"
  is a website banner phrase, NOT a motto — do not present it as one.
- Ideology: progresismo, socialdemocracia, socialismo democrático, allendismo,
  humanismo socialista, feminismo socialista. Position: centroizquierda a izquierda.
- Color: rojo. Youth wing: Juventud Socialista de Chile.
- Current (as of 2026) President: Paulina Vodanovic Rojas (desde 11-06-2022);
  Secretario General: Camilo Escalona. HQ: París 873, Santiago.

When writing any user-facing copy about the party, verify against this list or
the Wikipedia page; never invent slogans, founders, or dates.

## Layout

```
source/                         official text (verify against pschile.cl)
tools/parse_estatutos.ps1       source text -> app/assets/data/estatutos.json
app/                            the Flutter project
  assets/data/estatutos.json    GENERATED reading content (verbatim)
  assets/data/quiz.json         quiz bank (answers grounded in articles)
  lib/                          Dart source
```

## Toolchain notes (this machine)

- Android Studio, Android SDK (`%LOCALAPPDATA%\Android\Sdk`) and the bundled JDK
  are installed. **Flutter SDK is NOT installed** — see `README.md` for setup.
- Shell is **Windows PowerShell 5.1**, which reads `.ps1` files as ANSI. Keep
  script source pure ASCII: build accented regex characters from char codes
  (e.g. `[char]0x00CD` for `Í`). Also remember PowerShell variable names are
  **case-insensitive** (`$Ia` and `$ia` are the same variable).

## Regenerate content after editing the source text

```powershell
powershell -ExecutionPolicy Bypass -File tools\parse_estatutos.ps1
```

## Conventions

- App UI language is Spanish (Chilean). Code identifiers and comments in English.
- Colors and fonts come only from `lib/theme.dart`; do not hardcode colors in widgets.
- Keep the app fully offline: no network calls at runtime; all content is bundled.
