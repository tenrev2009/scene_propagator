# Guide Utilisateur — Scene Propagator

## 🎯 Objectif

Cette extension vous permet de **propager des propriétés de scène** (caméra, tags, style, ombres, etc.) depuis une scène source vers une ou plusieurs scènes cibles dans le **même modèle SketchUp**.

---

## 🚀 Démarrage rapide

1. Ouvrez un modèle SketchUp contenant plusieurs scènes
2. Lancez l’extension : `Extensions → Scene Propagator`
3. Choisissez :
   - **Scène source**
   - **Scènes cibles** (multi-sélection + filtres)
4. Sélectionnez les **propriétés à copier** via les cases à cocher
5. Cliquez sur `🔍 Aperçu` pour voir les changements à venir
6. Cliquez sur `✅ Appliquer` pour lancer la propagation

---

## 🧩 Propriétés copiables

- 📷 **Caméra** : position, angle, perspective
- 🏷️ **Tags** : visibilités par scène
- 🧱 **Objets masqués** : visibilité des entités
- 🪟 **Sections** : plan(s) de coupe actif(s)
- 🖌️ **Style** : y compris brouillard, arrière-plan, bords
- ☀️ **Ombres** : date, heure, intensité
- 🧭 **Axes** : position et orientation
- 🎞️ **Transitions** : durée, délai

---

## 🎚️ Préréglages

Plusieurs profils sont inclus :

| Nom            | Description                                     |
|----------------|-------------------------------------------------|
| Tout           | Active toutes les propriétés                   |
| Visuel         | Style, ombres, environnement                   |
| Organisation   | Tags, objets masqués, sections                 |
| Caméra seule   | Caméra uniquement                              |
| Personnalisé   | Mémorise le dernier choix                      |

Vous pouvez également :
- 💾 Enregistrer votre propre préréglage (bouton disquette)
- 🧠 Charger un préréglage existant

---

## 🧪 Aperçu des changements

Avant d’appliquer, utilisez `🔍 Aperçu` pour voir un **diff par scène cible**, exemple :

