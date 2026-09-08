# Vire-Langues 🇫🇷

Une application mobile **cross-platform** (Android & iOS) pour pratiquer les vire-langues avec des rappels quotidiens.

## 📱 Fonctionnalités

- ✅ **Bibliothèque complète** de vire-langues en français classés par catégorie et difficulté
- ✅ **Séries personnalisables** pour organiser vos vire-langues préférés
- ✅ **Notifications quotidiennes** à 20h00 pour ne jamais oublier de pratiquer
- ✅ **Suivi de progression** avec scores, niveaux et statistiques détaillées
- ✅ **Mode pratique** avec chronomètre et compteur de répétitions
- ✅ **Design moderne** avec Material 3 et thèmes clair/sombre
- ✅ **Statistiques** : streak, vire-langues maîtrisés, historique de pratique

## 🏗️ Architecture Technique

- **Framework**: [Flutter](https://flutter.dev/) 3.x
- **Gestion d'état**: [Riverpod](https://riverpod.dev/)
- **Stockage local**: [Hive](https://pub.dev/packages/hive) (NoSQL rapide)
- **Notifications**: [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications)
- **UI**: Material Design 3 avec thèmes personnalisés

## 📁 Structure du Projet

```
lib/
├── main.dart                 # Point d'entrée de l'application
├── theme/
│   └── app_theme.dart        # Thèmes et couleurs
├── models/
│   ├── vire_langue.dart      # Modèle VireLangue
│   ├── serie.dart            # Modèle Serie
│   └── progression.dart      # Modèle Progression
├── providers/
│   ├── vire_langue_provider.dart
│   ├── serie_provider.dart
│   └── progression_provider.dart
├── services/
│   ├── notification_service.dart  # Gestion des notifications
│   └── data_service.dart         # Initialisation des données
├── screens/
│   ├── splash_screen.dart
│   ├── home_screen.dart
│   ├── series_screen.dart
│   ├── practice_screen.dart
│   ├── statistics_screen.dart
│   └── settings_screen.dart
└── widgets/
    ├── vire_langue_card.dart
    ├── serie_card.dart
    ├── stat_card.dart
    └── star_rating.dart
```

## 🚀 Installation

### Prérequis

- Flutter SDK ≥ 3.0.0
- Android Studio / Xcode pour les émulateurs
- Un appareil Android (API 21+) ou iOS (12+)

### Étapes

```bash
# Cloner le dépôt
git clone https://github.com/Nicolous/vire-langues.git
cd vire-langues

# Installer les dépendances
flutter pub get

# Générer les fichiers Hive
flutter packages pub run build_runner build

# Lancer l'application
flutter run
```

## 📱 Captures d'Écran

| Accueil | Séries | Pratique |
|---------|--------|----------|
| ![Accueil](https://via.placeholder.com/300x600?text=Accueil) | ![Séries](https://via.placeholder.com/300x600?text=Séries) | ![Pratique](https://via.placeholder.com/300x600?text=Pratique) |

| Statistiques | Paramètres |
|-------------|-----------|
| ![Statistiques](https://via.placeholder.com/300x600?text=Statistiques) | ![Paramètres](https://via.placeholder.com/300x600?text=Paramètres) |

## 🎯 Catégories de Vire-Langues

- 🏆 **Classiques** : Les vire-langues traditionnels
- 😂 **Drôles** : Pour s'amuser en pratiquant
- 🐾 **Animaux** : Thématique animale
- 🍽️ **Nourriture** : Spécial gourmands
- ✈️ **Voyage** : Pour les amoureux des voyages
- 👥 **Personnages** : Histoires et personnages

## ⚙️ Configuration

### Notifications

Les notifications quotidiennes sont configurées par défaut à **20h00**. Vous pouvez modifier cette heure dans les paramètres.

### Personnalisation

- Créez vos propres séries de vire-langues
- Ajoutez des notes personnelles
- Suivez votre progression avec des étoiles (1-5)

## 📊 Statistiques

- **Streak** : Nombre de jours consécutifs de pratique
- **Score moyen** : Moyenne de tous vos scores
- **Vire-langues maîtrisés** : Ceux avec un score ≥ 90%
- **Historique** : Dernières sessions de pratique

## 🤝 Contribution

Les contributions sont les bienvenues ! Pour contribuer :

1. Forker le projet
2. Créer une branche (`git checkout -b feature/ma-fonctionnalite`)
3. Commiter vos changements (`git commit -m 'Ajout de ma fonctionnalite'`)
4. Pousser vers la branche (`git push origin feature/ma-fonctionnalite`)
5. Ouvrir une Pull Request

## 📄 Licence

Ce projet est sous licence **MIT**.

---

**Développé avec ❤️ par Nicolous**

*Améliorez votre élocution, un vire-langue à la fois !* 🎤
