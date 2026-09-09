import 'package:flutter/material.dart';
import 'package:vire_langues/models/vire_langue.dart';
import 'package:vire_langues/models/serie.dart';
import 'package:vire_langues/providers/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Service pour initialiser les donnees par defaut
class DataService {
  static final DataService _instance = DataService._internal();
  
  factory DataService() => _instance;
  
  DataService._internal();

  // Liste des vire-langues par defaut
  static const List<Map<String, dynamic>> _defaultVireLangues = [
    // Classiques - Facile
    {
      'texte': 'Un chasseur sachant chasser sait chasser sans son chien.',
      'difficulte': VireLangue.facile,
      'categorie': 'Classiques',
      'description': 'Le vire-langue classique par excellence.',
    },
    {
      'texte': 'Si six scies scient six cyprès, six cent six scies scient six cent six cyprès.',
      'difficulte': VireLangue.facile,
      'categorie': 'Classiques',
    },
    {
      'texte': 'Ton the t\'a-t-il ôte ta toux ? Oui, mon the m\'a ôte ma toux.',
      'difficulte': VireLangue.facile,
      'categorie': 'Classiques',
    },
    {
      'texte': 'Pauvre petit pêcheur, prends patience pour pouvoir prendre plusieurs petits poissons.',
      'difficulte': VireLangue.facile,
      'categorie': 'Classiques',
    },
    
    // Classiques - Moyen
    {
      'texte': 'Je suis ce que je suis, et si je suis ce que je suis, qu\'est-ce que je suis ?',
      'difficulte': VireLangue.moyen,
      'categorie': 'Classiques',
    },
    {
      'texte': 'Le mur murant Paris rend Paris murmurant.',
      'difficulte': VireLangue.moyen,
      'categorie': 'Classiques',
    },
    {
      'texte': 'Gros gras grand grain d\'orge, quand te de-gros-gras-grand-grain-d\'orge-ifieras-tu ?',
      'difficulte': VireLangue.moyen,
      'categorie': 'Classiques',
    },
    {
      'texte': 'Si mon tonton tond ton tonton, ton tonton sera tondu.',
      'difficulte': VireLangue.moyen,
      'categorie': 'Classiques',
    },
    
    // Classiques - Difficile
    {
      'texte': 'Je veux et j\'exige d\'exquises excuses.',
      'difficulte': VireLangue.difficile,
      'categorie': 'Classiques',
    },
    {
      'texte': 'Le chasseur sait chasser sans son chien de chasse.',
      'difficulte': VireLangue.difficile,
      'categorie': 'Classiques',
    },
    {
      'texte': 'Blanche porte de corail que l\'on corroie, corroyez, corroyons, corroyez.',
      'difficulte': VireLangue.difficile,
      'categorie': 'Classiques',
    },
    
    // Drôles - Facile
    {
      'texte': 'Le ver vert va vers le verre vert.',
      'difficulte': VireLangue.facile,
      'categorie': 'Drôles',
    },
    {
      'texte': 'Un dragon grade degrade un dragon grade.',
      'difficulte': VireLangue.facile,
      'categorie': 'Drôles',
    },
    
    // Drôles - Moyen
    {
      'texte': 'Si sans sous, c\'est sous, sous sans si, c\'est si.',
      'difficulte': VireLangue.moyen,
      'categorie': 'Drôles',
    },
    {
      'texte': 'Le therapeute therapeuthe therapeutise le therapeute.',
      'difficulte': VireLangue.moyen,
      'categorie': 'Drôles',
    },
    
    // Drôles - Difficile
    {
      'texte': 'Je suis un saucisson sec, je suis un saucisson sec.',
      'difficulte': VireLangue.difficile,
      'categorie': 'Drôles',
    },
    {
      'texte': 'Pauvre petit pêcheur, prends patience pour pouvoir prendre plusieurs petits poissons pour toi.',
      'difficulte': VireLangue.difficile,
      'categorie': 'Drôles',
    },
    
    // Animaux - Facile
    {
      'texte': 'Le rat rose ronge la racine du rosier.',
      'difficulte': VireLangue.facile,
      'categorie': 'Animaux',
    },
    {
      'texte': 'Le chat chasse la souris.',
      'difficulte': VireLangue.facile,
      'categorie': 'Animaux',
    },
    
    // Animaux - Moyen
    {
      'texte': 'Trois tortues trottinent sur un trottoir très etroit.',
      'difficulte': VireLangue.moyen,
      'categorie': 'Animaux',
    },
    {
      'texte': 'Le hibou hue, hue le hibou.',
      'difficulte': VireLangue.moyen,
      'categorie': 'Animaux',
    },
    
    // Animaux - Difficile
    {
      'texte': 'Le coq cocorico coquin coquille le coq cocorico.',
      'difficulte': VireLangue.difficile,
      'categorie': 'Animaux',
    },
    {
      'texte': 'Si six scies scient six cyprès, six cent six scies scient six cent six cyprès.',
      'difficulte': VireLangue.difficile,
      'categorie': 'Animaux',
    },
    
    // Nourriture - Facile
    {
      'texte': 'Pelle le poivron et pèle le pompon.',
      'difficulte': VireLangue.facile,
      'categorie': 'Nourriture',
    },
    {
      'texte': 'La farine fait farine.',
      'difficulte': VireLangue.facile,
      'categorie': 'Nourriture',
    },
    
    // Nourriture - Moyen
    {
      'texte': 'Le cuistot cuit, le cuistot cuit, le cuistot cuit.',
      'difficulte': VireLangue.moyen,
      'categorie': 'Nourriture',
    },
    {
      'texte': 'Pauvre petit pain perce, prends patience pour être petris.',
      'difficulte': VireLangue.moyen,
      'categorie': 'Nourriture',
    },
    
    // Nourriture - Difficile
    {
      'texte': 'Je suis le cuistot qui cuit les cuisses du coq qui coqorico.',
      'difficulte': VireLangue.difficile,
      'categorie': 'Nourriture',
    },
    
    // Voyage - Facile
    {
      'texte': 'Paris paname, paname Paris.',
      'difficulte': VireLangue.facile,
      'categorie': 'Voyage',
    },
    {
      'texte': 'Je vais a la ville, je viens de la ville.',
      'difficulte': VireLangue.facile,
      'categorie': 'Voyage',
    },
    
    // Voyage - Moyen
    {
      'texte': 'Le voyageur voyage en voiture de voyage.',
      'difficulte': VireLangue.moyen,
      'categorie': 'Voyage',
    },
    {
      'texte': 'Je pars, je pars pas, je pars, je pars pas.',
      'difficulte': VireLangue.moyen,
      'categorie': 'Voyage',
    },
    
    // Voyage - Difficile
    {
      'texte': 'Le mur de la ville de Paris est mure par les murs de la ville de Paris.',
      'difficulte': VireLangue.difficile,
      'categorie': 'Voyage',
    },
    
    // Personnages - Facile
    {
      'texte': 'Louis loue une loyer loue par Louis.',
      'difficulte': VireLangue.facile,
      'categorie': 'Personnages',
    },
    {
      'texte': 'Pierre pèle un pompon pour Paul.',
      'difficulte': VireLangue.facile,
      'categorie': 'Personnages',
    },
    
    // Personnages - Moyen
    {
      'texte': 'Le roi de France est un roi franc.',
      'difficulte': VireLangue.moyen,
      'categorie': 'Personnages',
    },
    {
      'texte': 'Jean jeûne a jeun, jeûne Jean a jeun.',
      'difficulte': VireLangue.moyen,
      'categorie': 'Personnages',
    },
    
    // Personnages - Difficile
    {
      'texte': 'Le therapeute therapeuthe therapeutise le therapeute therapeuthe.',
      'difficulte': VireLangue.difficile,
      'categorie': 'Personnages',
    },
  ];

  // Series par defaut
  static const List<Map<String, dynamic>> _defaultSeries = [
    {
      'nom': 'Debutant - Classiques',
      'description': 'Une selection de vire-langues classiques pour debuter.',
      'vireLangueIds': [
        '0001', '0002', '0003', '0004',
      ],
      'estPersonnalisee': false,
    },
    {
      'nom': 'Intermediaire - Classiques',
      'description': 'Des vire-langues classiques de difficulte moyenne.',
      'vireLangueIds': [
        '0005', '0006', '0007', '0008',
      ],
      'estPersonnalisee': false,
    },
    {
      'nom': 'Avance - Classiques',
      'description': 'Les vire-langues classiques les plus difficiles.',
      'vireLangueIds': [
        '0009', '0010', '0011',
      ],
      'estPersonnalisee': false,
    },
    {
      'nom': 'Mix Drôles',
      'description': 'Une selection de vire-langues drôles de toutes difficultes.',
      'vireLangueIds': [
        '0012', '0013', '0014', '0015', '0016',
      ],
      'estPersonnalisee': false,
    },
    {
      'nom': 'Animaux',
      'description': 'Tous les vire-langues sur le thème des animaux.',
      'vireLangueIds': [
        '0017', '0018', '0019', '0020', '0021', '0022',
      ],
      'estPersonnalisee': false,
    },
    {
      'nom': 'Defi Complet',
      'description': 'Tous les vire-langues pour un entraînement complet.',
      'vireLangueIds': [], // Sera rempli dynamiquement
      'estPersonnalisee': false,
    },
  ];

  /// Initialiser les donnees par defaut si elles n'existent pas
  Future<void> initializeDefaultData(WidgetRef ref) async {
    final vireLangueNotifier = ref.read(vireLangueNotifierProvider.notifier);
    final serieNotifier = ref.read(serieNotifierProvider.notifier);
    
    // Verifier si des vire-langues existent deja
    final vireLangues = ref.read(vireLanguesProvider);
    
    if (vireLangues.isEmpty) {
      debugPrint('Initialisation des vire-langues par defaut...');
      
      // Ajouter les vire-langues par defaut
      for (var i = 0; i < _defaultVireLangues.length; i++) {
        final data = _defaultVireLangues[i];
        final id = 'VL${(i + 1).toString().padLeft(4, '0')}';
        
        vireLangueNotifier.create(
          texte: data['texte']!,
          difficulte: data['difficulte']!,
          categorie: data['categorie']!,
          description: data['description'],
        );
      }
      
      debugPrint('Vire-langues par defaut ajoutes.');
    }
    
    // Verifier si des series existent deja
    final series = ref.read(seriesProvider);
    
    if (series.isEmpty) {
      debugPrint('Initialisation des series par defaut...');
      
      // Obtenir tous les vire-langues pour la serie complète
      final allVireLangues = ref.read(vireLanguesProvider);
      final allIds = allVireLangues.map((vl) => vl.id).toList();
      
      // Ajouter les series par defaut
      for (var i = 0; i < _defaultSeries.length; i++) {
        final data = _defaultSeries[i];
        final id = 'S${(i + 1).toString().padLeft(4, '0')}';
        
        // Pour la serie complète, utiliser tous les IDs
        final vireLangueIds = data['vireLangueIds'] is List 
            ? List<String>.from(data['vireLangueIds'])
            : allIds;
        
        // Creer la serie avec des IDs valides
        final validIds = vireLangueIds
            .where((id) => allVireLangues.any((vl) => vl.id == id))
            .toList();
        
        if (validIds.isNotEmpty) {
          serieNotifier.create(
            nom: data['nom']!,
            description: data['description']!,
            vireLangueIds: validIds,
            estPersonnalisee: data['estPersonnalisee'] ?? false,
          );
        }
      }
      
      debugPrint('Series par defaut ajoutees.');
    }
  }

  /// Reinitialiser toutes les donnees
  Future<void> resetAllData(WidgetRef ref) async {
    final vireLangueBox = ref.read(vireLangueBoxProvider);
    final serieBox = ref.read(serieBoxProvider);
    final progressionBox = ref.read(progressionBoxProvider);
    
    // Supprimer toutes les donnees
    await vireLangueBox.clear();
    await serieBox.clear();
    await progressionBox.clear();
    
    debugPrint('Toutes les donnees ont ete reinitialisees.');
  }

  /// Obtenir les statistiques des donnees
  Map<String, dynamic> getDataStatistics(WidgetRef ref) {
    final vireLangues = ref.read(vireLanguesProvider);
    final series = ref.read(seriesProvider);
    final progressions = ref.read(progressionsProvider);
    
    final vireLanguesParCategorie = <String, int>{};
    final vireLanguesParDifficulte = <String, int>{};
    
    for (final vl in vireLangues) {
      vireLanguesParCategorie[vl.categorie] = 
          (vireLanguesParCategorie[vl.categorie] ?? 0) + 1;
      
      vireLanguesParDifficulte[vl.difficulteLibelle] = 
          (vireLanguesParDifficulte[vl.difficulteLibelle] ?? 0) + 1;
    }
    
    return {
      'totalVireLangues': vireLangues.length,
      'totalSeries': series.length,
      'totalProgressions': progressions.length,
      'vireLanguesParCategorie': vireLanguesParCategorie,
      'vireLanguesParDifficulte': vireLanguesParDifficulte,
    };
  }
}
