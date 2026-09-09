import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:vire_langues/models/serie.dart';

// Provider pour la boîte Hive des series
final serieBoxProvider = Provider<Box<Serie>>((ref) {
  return Hive.box<Serie>('series');
});

// Provider pour la liste de toutes les series
final seriesProvider = Provider<List<Serie>>((ref) {
  final box = ref.watch(serieBoxProvider);
  return box.values.toList();
});

// Provider pour les series personnalisees
final seriesPersonnaliseesProvider = Provider<List<Serie>>((ref) {
  final series = ref.watch(seriesProvider);
  return series.where((s) => s.estPersonnalisee).toList();
});

// Provider pour les series par defaut
final seriesParDefautProvider = Provider<List<Serie>>((ref) {
  final series = ref.watch(seriesProvider);
  return series.where((s) => !s.estPersonnalisee).toList();
});

// Notifier pour gerer les series
class SerieNotifier extends StateNotifier<List<Serie>> {
  final Box<Serie> _box;
  
  SerieNotifier(this._box) : super(_box.values.toList());

  // Ajouter une serie
  void add(Serie serie) {
    _box.put(serie.id, serie);
    state = _box.values.toList();
  }

  // Mettre a jour une serie
  void update(Serie serie) {
    _box.put(serie.id, serie.copyWith(
      dateModification: DateTime.now(),
    ));
    state = _box.values.toList();
  }

  // Supprimer une serie
  void delete(String id) {
    _box.delete(id);
    state = _box.values.toList();
  }

  // Obtenir une serie par ID
  Serie? getById(String id) {
    return _box.get(id);
  }

  // Creer une serie avec un ID auto-genere
  Serie create({
    required String nom,
    required String description,
    required List<String> vireLangueIds,
    bool estPersonnalisee = true,
  }) {
    final id = const Uuid().v4();
    final serie = Serie(
      id: id,
      nom: nom,
      description: description,
      vireLangueIds: vireLangueIds,
      estPersonnalisee: estPersonnalisee,
    );
    add(serie);
    return serie;
  }

  // Obtenir les series contenant un vire-langue specifique
  List<Serie> getSeriesAvecVireLangue(String vireLangueId) {
    return state
        .where((s) => s.vireLangueIds.contains(vireLangueId))
        .toList();
  }

  // Rechercher des series
  List<Serie> search(String query) {
    return state
        .where((s) => 
          s.nom.toLowerCase().contains(query.toLowerCase()) ||
          s.description.toLowerCase().contains(query.toLowerCase())
        )
        .toList();
  }
}

// Provider pour le notifier
final serieNotifierProvider = StateNotifierProvider<SerieNotifier, List<Serie>>((ref) {
  final box = ref.watch(serieBoxProvider);
  return SerieNotifier(box);
});
