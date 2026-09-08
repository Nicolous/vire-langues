import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:vire_langues/models/vire_langue.dart';

// Provider pour la boîte Hive des vire-langues
final vireLangueBoxProvider = Provider<Box<VireLangue>>((ref) {
  return Hive.box<VireLangue>('vire_langues');
});

// Provider pour la liste de tous les vire-langues
final vireLanguesProvider = Provider<List<VireLangue>>((ref) {
  final box = ref.watch(vireLangueBoxProvider);
  return box.values.toList();
});

// Provider pour les vire-langues par catégorie
final vireLanguesParCategorieProvider = 
    Provider.family<List<VireLangue>, String>((ref, categorie) {
  final vireLangues = ref.watch(vireLanguesProvider);
  return vireLangues.where((vl) => vl.categorie == categorie).toList();
});

// Provider pour les vire-langues par difficulté
final vireLanguesParDifficulteProvider = 
    Provider.family<List<VireLangue>, int>((ref, difficulte) {
  final vireLangues = ref.watch(vireLanguesProvider);
  return vireLangues.where((vl) => vl.difficulte == difficulte).toList();
});

// Notifier pour gérer les vire-langues
class VireLangueNotifier extends StateNotifier<List<VireLangue>> {
  final Box<VireLangue> _box;
  
  VireLangueNotifier(this._box) : super(_box.values.toList());

  // Ajouter un vire-langue
  void add(VireLangue vireLangue) {
    _box.put(vireLangue.id, vireLangue);
    state = _box.values.toList();
  }

  // Mettre à jour un vire-langue
  void update(VireLangue vireLangue) {
    _box.put(vireLangue.id, vireLangue);
    state = _box.values.toList();
  }

  // Supprimer un vire-langue
  void delete(String id) {
    _box.delete(id);
    state = _box.values.toList();
  }

  // Obtenir un vire-langue par ID
  VireLangue? getById(String id) {
    return _box.get(id);
  }

  // Créer un vire-langue avec un ID auto-généré
  VireLangue create({
    required String texte,
    required int difficulte,
    required String categorie,
    String? description,
  }) {
    final id = const Uuid().v4();
    final vireLangue = VireLangue(
      id: id,
      texte: texte,
      difficulte: difficulte,
      categorie: categorie,
      description: description,
    );
    add(vireLangue);
    return vireLangue;
  }

  // Obtenir un vire-langue aléatoire
  VireLangue? getRandom() {
    if (state.isEmpty) return null;
    final index = DateTime.now().millisecondsSinceEpoch % state.length;
    return state[index];
  }

  // Rechercher des vire-langues
  List<VireLangue> search(String query) {
    return state
        .where((vl) => 
          vl.texte.toLowerCase().contains(query.toLowerCase()) ||
          vl.categorie.toLowerCase().contains(query.toLowerCase()) ||
          (vl.description?.toLowerCase().contains(query.toLowerCase()) ?? false)
        )
        .toList();
  }
}

// Provider pour le notifier
final vireLangueNotifierProvider = StateNotifierProvider<VireLangueNotifier, List<VireLangue>>((ref) {
  final box = ref.watch(vireLangueBoxProvider);
  return VireLangueNotifier(box);
});
