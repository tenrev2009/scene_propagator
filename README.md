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
- **Gestion des scènes :**
  - ✏️ **Renommer** une scène existante directement depuis l'interface.
  - ➕ **Créer** de nouvelles scènes en lot (nombre désiré), avec insertion possible **après une scène existante au choix**.
  - 🔢 **Nommage indexé** : `préfixe + indice préfixe + nom + suffixe + indice suffixe` (ex : nom `toto`, préfixe `cc`, suffixe `dd`, indices `01` → `cc01totodd01`, `cc02totodd02`…). Le format saisi définit le remplissage (`0` → 0,1,2… ; `01` → 01,02,03…), chaque indice peut être incrémenté ou fixe, avec un pas réglable (1, 2, …).
  - 🎯 Les nouvelles scènes peuvent **hériter des propriétés d'une scène source** (caméra, style, ombres, calques…).
  - 🔁 **Renommage en groupe** des scènes cochées, suivant la même logique de nommage indexé.
  - 📄 **Export/Import CSV** des noms de scènes : exportez l'ordre actuel, ou importez un fichier pour remplacer les noms existants (avec avertissement si le nombre de lignes ne correspond pas).
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

Ce dépôt contient les sources du plugin ; aucun `.rbz` n'y est publié directement. Deux façons de l'installer :

### Option A — Construire le `.rbz` soi-même

```bash
./build_rbz.sh
```

Le fichier est généré dans `dist/scene_propagator-<version>.rbz`. Ensuite, dans SketchUp :
`Fenêtre` → `Gestionnaire d'extensions` → `Installer une extension` → sélectionnez ce fichier.

### Option B — Installation manuelle depuis les sources

1. Copiez `scene_propagator.rb` et le dossier `ScenePropagator/` dans le dossier `Plugins` de SketchUp :
   - Windows : `%APPDATA%\SketchUp\SketchUp <version>\SketchUp\Plugins`
   - macOS : `~/Library/Application Support/SketchUp <version>/SketchUp/Plugins`
2. Relancez SketchUp.

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
