# 📱 Application de Gestion des Besoins Quotidiens

## 🎯 Objectif
Créer une application mobile (Android/iOS) permettant à un utilisateur d’ajouter, consulter, modifier et supprimer des **besoins quotidiens** (achats/dépenses personnelles) pour chaque jour sans limitation de dates. L'application affichera également un **récapitulatif journalier** (total MGA par jour) et un **suivi mensuel**.

---

## 🧩 Fonctionnalités Principales

### 📅 Gestion par Date
- Afficher une **liste des jours** (ex: sous forme de `cards`) où des besoins ont été ajoutés.
- En cliquant sur une **carte d’un jour**, afficher la liste des besoins de cette journée.

### ➕ Ajouter un Besoin
- Champs : 
  - `titre` (string)
  - `description` (string facultatif)
  - `prix` en MGA (entier ou float)
  - `date` (datetime, auto ou manuelle)
- Chaque besoin est lié à une date spécifique.

### 📄 Liste des Besoins Journaliers
- Affichage sous forme de liste.
- Afficher les **totaux MGA** en bas de chaque journée.

### ❌ Supprimer / ✏️ Modifier un Besoin
- L’utilisateur peut **éditer** ou **supprimer** un besoin.

### 🧮 Résumé Mensuel
- Affichage des **totaux MGA par mois**.
- Option : graphe ou tableau synthétique (bonus).

---

## 🖌️ Interface Utilisateur
- **Design moderne, intuitif et minimaliste**.
- Utilisation de composants classiques (cards, listviews, modals).
- UX fluide : transitions douces, feedback utilisateur (snackbars/toasts).

---

## 🗃️ Base de Données (locale)
- Utiliser **SQLite** via un package adapté au framework mobile choisi (ex: `sqflite` pour Flutter).
- Modèle de données :
  ```sql
  Table: besoins
  - id (primary key)
  - titre (text)
  - description (text)
  - prix (real)
  - date (datetime)

## Base de Données & State Management
yaml
# Packages Flutter matures et stables
dependencies:
  flutter_riverpod: ^2.4.0 
  isar: ^3.1.0  # Plus performant que SQLite
  isar_flutter_libs: ^3.1.0

flutter pub add flutter_riverpod
flutter pub add riverpod_annotation
flutter pub add dev:riverpod_generator
flutter pub add dev:build_runner
flutter pub add dev:custom_lint
flutter pub add dev:riverpod_lint

# Navigation & Routing
dartgo_router: ^12.0.0 