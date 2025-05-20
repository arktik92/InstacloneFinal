# Application Stories - Test Technique

## Vue d'ensemble
Cette application implémente une fonctionnalité similaire aux Stories d'Instagram pour iOS, développée avec Swift et SwiftUI. Elle permet aux utilisateurs de parcourir des stories, de les visualiser avec des gestes interactifs et d'interagir avec elles via des likes. Les stories conservent leur état (vu/non vu, aimé) entre les sessions de l'application.

## Fonctionnalités principales
- **Liste de Stories**: Liste horizontale défilante des stories des utilisateurs avec indicateurs vu/non vu
- **Pagination infinie**: Chargement continu des stories lors du défilement
- **Visualiseur de Stories**: Vue plein écran pour regarder les stories avec contrôles gestuels
- **Gestion d'état**: Suivi des états vu/non vu et aimé
- **Persistance**: États des stories conservés entre les sessions via UserDefaults
- **Gestes interactifs**:
  - Appui gauche/droite pour naviguer entre les images
  - Appui long pour mettre en pause la lecture
  - Double tap pour aimer une story
  - Glissement horizontal pour naviguer entre utilisateurs
  - Glissement vertical pour fermer la story

## Architecture
L'application suit le modèle d'architecture **MVVM (Model-View-ViewModel)** avec une couche de service pour la gestion des données:

### Modèles
- `User`: Représente un utilisateur avec ses informations de profil
- `Story`: Contient les données de la story, y compris les images et l'index de visualisation actuel
- `UserStoryState`: Gère l'état d'une story (vue, aimée, dernier index consulté)
- `FeedPost`: Représente un post du fil d'actualité (pour le flux principal sous les stories)

### Vues
- `StoriesListView`: Vue principale affichant la liste des stories et des posts
- `StoryView`: Vue plein écran pour afficher et interagir avec les stories
- `StoryAvatarView`: Affiche l'avatar de l'utilisateur avec indicateur vu/non vu
- `StoryProgressView`: Montre la progression à travers les multiples images d'une story
- `FeedPostView`: Affiche les posts dans le fil d'actualité principal

### ViewModels
- `StoriesListViewModel`: Gère les données de la liste des stories et la logique de pagination
- `StoryViewModel`: Contrôle l'expérience de visionnage incluant le timing et les transitions

### Services
- `WebService`: Gère les requêtes réseau avec Alamofire
- `StoryStateService`: Gère la persistance des états des stories
- `StoriesService`: Coordonne les viewmodels et les services de données

## Décisions techniques

### SwiftUI
J'ai choisi SwiftUI comme framework UI principal pour ce projet car:
- Il offre une approche moderne et déclarative pour construire des interfaces
- Il simplifie la gestion d'état grâce aux property wrappers
- Il propose des animations et transitions intégrées qui améliorent l'expérience utilisateur
- Il s'intègre parfaitement avec le modèle d'architecture MVVM

### Sources de données
- Les données utilisateurs sont chargées depuis un fichier JSON local (comme indiqué dans les exigences du test)
- Les images des stories sont récupérées depuis une API d'images aléatoires (picsum.photos)
- Cette approche garantit que les données sont structurées de manière cohérente tout en chargeant les images dynamiquement

### Bibliothèques externes
- **Alamofire**: Utilisé pour les requêtes réseau en raison de:
  - Son API propre et chaînable pour construire des requêtes
  - Sa gestion d'erreurs intégrée et sa validation de réponse
  - Sa gestion robuste des opérations asynchrones
  - Sa large adoption dans la communauté de développement iOS

### Persistance
- Utilisation de UserDefaults pour persister les états des stories (vu/aimé)
- Cette approche est:
  - Simple à implémenter pour la portée requise
  - Suffisante pour la quantité de données à stocker
  - Accessible entre les sessions de l'application

### Considérations UI/UX
- Implémentation d'indicateurs visuels pour les états des stories (anneaux colorés autour des avatars)
- Ajout d'animations fluides pour les transitions et interactions
- Création d'une fonctionnalité de double tap pour aimer avec animation de cœur
- Conception de contrôles gestuels intuitifs correspondant au comportement d'Instagram

## Hypothèses et limitations

1. **Génération de données**: L'application génère du contenu aléatoire pour les stories puisque le test spécifiait que "les données n'importent pas" tant qu'elles sont cohérentes pour chaque utilisateur
2. **Persistance**: UserDefaults est adéquat pour cette démo, mais une solution plus robuste serait nécessaire pour une application en production
3. **Gestion d'erreurs**: Une gestion d'erreurs basique est implémentée; une application en production nécessiterait une gestion plus complète
4. **Chargement d'images**: Aucune mise en cache d'images au-delà de celle fournie par le système n'est implémentée, ce qui serait essentiel pour un environnement de production
5. **Performance**: L'implémentation actuelle se concentre sur la fonctionnalité plutôt que sur l'optimisation des performances

## Améliorations potentielles

- Implémenter une solution de persistance de données plus robuste (Core Data, Realm)
- Ajouter une mise en cache des images avec une bibliothèque comme Kingfisher ou SDWebImage
- Implémenter le préchargement d'images pour des transitions plus fluides
- Améliorer la gestion des erreurs et les mécanismes de réessai
- Ajouter des tests unitaires et d'interface utilisateur
- Prendre en charge le contenu vidéo dans les stories
- Ajouter des fonctionnalités d'accessibilité
- Optimiser les performances pour un grand nombre de stories

## Instructions de compilation

1. Cloner le dépôt
2. Ouvrir le projet dans Xcode
3. Exécuter `pod install` si des dépendances doivent être installées
4. Compiler et exécuter sur simulateur ou appareil

## Prérequis
- iOS 16.0+
- Swift 5.8+
- Xcode 15.0+
