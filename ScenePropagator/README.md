# Scene Propagator

**Scene Propagator** est une extension SketchUp (2020–2025, Windows/macOS) qui vous permet de copier précisément des propriétés d’une scène source vers plusieurs scènes cibles dans un même modèle. L’interface moderne et localisable (FR/EN) permet un contrôle fin grâce à des cases à cocher et des préréglages enregistrables.

## ✅ Fonctionnalités principales

- Choix d’une scène source + sélection multiple des scènes cibles
- Propagation granulaire : caméra, ombres, style, tags, sections, axes, etc.
- Préréglages configurables (Tout, Visuel, Organisation, Caméra seule…)
- Aperçu des changements (diff) avant application
- Journal d’exécution exportable (.json, .csv)
- Interface moderne via HtmlDialog, responsive et localisée
- Undo global en une seule étape

## 📦 Installation

1. Téléchargez le fichier `scene_propagator.rbz`
2. Dans SketchUp : `Fenêtre` → `Gestionnaire d'extensions` → `Installer une extension`
3. Sélectionnez le `.rbz` et validez
4. Accédez à l’extension via :
   - Menu `Extensions → Scene Propagator`
   - Ou barre d’outils `Scene Propagator` (icône)

## 🖥️ Compatibilité

- SketchUp 2020 à 2025
- Windows & macOS
- Ruby 2.7–3.2

## 📁 Structure technique

L’extension suit une architecture modulaire claire (`ScenePropagator/`) avec séparation des responsabilités : services, infrastructure, interface, etc.

## 🔤 Internationalisation

La langue est automatiquement détectée selon SketchUp (`Sketchup.get_locale`). Langues disponibles :
- 🇫🇷 Français
- 🇬🇧 Anglais

## ⚖️ Licence

MIT — voir fichier `LICENSE`

## 📫 Support

- Site officiel : [https://votre.site/support](https://votre.site/support)
- Forum : [https://forums.sketchup.com](https://forums.sketchup.com)
