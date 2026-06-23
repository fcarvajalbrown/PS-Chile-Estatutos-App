# Roadmap — PS Chile Formación

Planned work from the current 1.0 release up to 2.0, in 0.1 steps. Each version is
a focused milestone. Done items live in git history, not here.

Content-integrity rules still apply to every milestone: never invent or paraphrase
statute text, every quiz answer is grounded in an `articleRef`, and any new fact /
callout / glossary entry must be verifiable against `source/` or an authoritative
party fact before it ships.

## 1.1 — Mid-article facts

Make "Datos clave" fact boxes and "¿Sabías que?" callouts appear *within* the
article text, like a book, instead of only after the last paragraph.

- Add an optional `"afterParagraph": N` field to **both** `factboxes.json` and
  `callouts.json`. The reader inserts the box right after paragraph N; if the field
  is omitted it renders at the end of the article, exactly as today (backward
  compatible, fully data-driven — no source-text edits, no parser changes).
- Update `reader_screen.dart` to interleave boxes between paragraphs based on the
  anchor.
- Reposition the 8 existing fact boxes and current callouts to read well
  mid-article. No new facts invented.
- Rename the product to **"PS Chile Formación"** everywhere it is named:
  AndroidManifest `android:label`, the home header/title in `home_screen.dart`, and
  the `pubspec.yaml` description.

## 1.2 — Reader niceties

- **Continue reading / last-read:** remember the last article opened and surface a
  "Seguir leyendo" entry on the home screen (reuses the shared_preferences store).
- **Adjustable text size:** A-/A+ control for the article body, persisted.
- **Bookmarks:** star articles and view a saved list.

## 1.3 — In-app search

- Full-text search across all article bodies and headings, fully offline (indexes
  the bundled `estatutos.json`).
- Tap a result to open that article with the matched text highlighted.

## 1.4 — Quiz: repasar los fallados

- **Review-missed mode:** track questions answered wrong (by the existing question
  id) and offer a quiz built only from those until answered correctly.
- **Per-Título quiz mastery:** show best score / % correct per Título so weak areas
  are visible (polishes the existing badges/progress).
- **Quiz expansion to full coverage:** grow the bank so every Título has solid
  coverage across all three difficulty tiers, each question grounded in an
  `articleRef`. Shipped here because review-missed and mastery scores are only
  meaningful over a sizeable bank.

## 1.5 — Dark mode

- A dark theme in the PS palette (colors stay in `lib/theme.dart`).
- Follows the device theme by default, with a manual light/dark override, persisted.

## 1.6 — Onboarding tour

- A short first-run walkthrough of Leer / Curso / Progreso, shown once, skippable.

## 1.7 — Glossary of terms

- A tappable glossary for statute/party jargon (quórum, pleno, célula, etc.).
- Sources are researched and verified when the feature is built; no invented
  definitions. Statute-defined terms link back to the article that defines them.

## 1.8 — Release readiness

- Signing config for release builds.
- Produce a **signed APK** (direct sharing / sideload) and a **Play app bundle**
  (.aab), plus store-listing prep (description, screenshots).

## 1.9 — Share / export

- **Share an article** as text with its reference (verbatim statute text only).
- **Share a quiz result** (score card after finishing a quiz).
- **Export / back up progress** (read articles, scores, streak) to a file the user
  can keep or restore.

## 2.0 — Content completeness + freshness

The "content is complete and current" release.

- Re-run `tools/parse_estatutos.ps1` against pschile.cl and reconcile any newer
  statute version (current: updated 2026-05-19).
- Complete fact-box / callout coverage across all Títulos.
- Polished Allende portrait — verify and iterate `allende_portrait.dart` on a real
  render.
- Broad polish pass: animations, accessibility, and performance across the whole
  app. Landed here because 2.0 is the flagship release and this follows all feature
  work, so nothing gets polished twice.

## 2.0+ — iOS

- Take the existing iOS scaffolding to a real, runnable and distributable build.
  Deliberately after 2.0: the audience is overwhelmingly Android, so iPhone support
  is a follow-on rather than a launch requirement.

