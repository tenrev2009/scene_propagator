# Scene Propagator

**Scene Propagator** est une extension puissante pour SketchUp (compatible 2020–2026) conçue pour copier fidèlement les propriétés d’une scène source vers plusieurs scènes cibles. 

Contrairement à l'outil natif, cette extension permet une **propagation granulaire** (choisir exactement quoi copier) et garantit une fidélité visuelle totale (objets cachés spécifiques, plans de coupe actifs, surcharges de style) grâce à une méthode de capture basée sur le contexte de la vue.

## ✅ Fonctionnalités principales

- **Sélection précise :** Choisissez une scène source et cochez les scènes cibles (filtre de recherche inclus).
- **Contrôle granulaire :** Copiez uniquement ce que vous voulez :
  - 📷 **Caméra :** Position, cible, FOV.
  - 🏷️ **Tags (Calques) :** État visible/masqué synchronisé parfaitement.
  - 👻 **Géométrie cachée :** Capture les objets et guides masqués spécifiquement (ID uniques).
  - 🖌️ **Style & Environnement :** Styles, brouillard, arrière-plan et surcharges de style.
  - ☀️ **Ombres :** Date, heure, et paramètres d'affichage.
  - ✂️ **Coupes :** Plans de coupe actifs.
  - 🧭 **Axes :** Position des axes personnalisés.
- **Préréglages (Presets) :** Enregistrez vos configurations favorites (ex: "Tout copier", "Juste la caméra").
- **Aperçu (Diff) :** Visualisez les différences avant d'appliquer (expérimental).
- **Journal d’exécution :** Log détaillé exportable en `.json` ou `.csv` pour le débogage.
- **Undo Global :** Annulation en une seule étape (Ctrl+Z).

## 🚀 Utilisation

1. Ouvrez l'extension via `Extensions > Scene Propagator` ou la barre d'outils.
2. Sélectionnez la **Scène Source** (celle qui contient les bons réglages).
3. Cochez les **Scènes Cibles** (celles à modifier).
4. Choisissez les propriétés à propager (Scope).
5. Cliquez sur **Apply** (Appliquer).

> **Note importante :** Pour garantir une copie exacte des objets cachés et des styles, l'extension va **temporairement basculer l'affichage sur la scène source** pendant le processus. C'est un comportement normal nécessaire pour capturer le contexte visuel ("What You See Is What You Get").

## 📦 Installation

1. Téléchargez le fichier `.rbz`.
2. Dans SketchUp : `Fenêtre` → `Gestionnaire d'extensions` → `Installer une extension`.
3. Sélectionnez le fichier `.rbz`.

## 🖥️ Compatibilité

- **SketchUp :** 2020, 2021, 2022, 2023, 2024, 2025, 2026.
- **OS :** Windows & macOS.
- **Ruby :** Supporte Ruby 2.7 jusqu'à 3.2+ (encodage UTF-8/ASCII safe).

## 🌐 Internationalisation

L'interface s'adapte automatiquement à la langue de SketchUp :
- 🇫🇷 Français
- 🇬🇧 Anglais (par défaut)

## 📁 Structure Technique

- `core/` : Logique métier (CopyService, DiffService).
- `ui/` : Interface utilisateur (HtmlDialog, Vue.js/Vanilla JS).
- `infra/` : Logger, I18n.
- `presets/` : Stockage des préréglages utilisateur JSON.

## ⚖️ Licence

MIT — Voir le fichier `LICENSE` pour plus de détails.

---
**Développé par tenrev - biblio3d**
