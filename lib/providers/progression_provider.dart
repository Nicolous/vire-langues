import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:vire_langues/models/progression.dart';
import 'package:vire_langues/models/vire_langue.dart';

// Provider pour la boîte Hive des progressions
final progressionBoxProvider = Provider<Box<Progression>>((ref) {
  return Hive.box<Progression>('progression');
});

// Provider pour la liste de toutes les progressions
final progressionsProvider = Provider<List<Progression>>((ref) {
  final box = ref.watch(progressionBoxProvider);
  return box.values.toList();
});

// Provider pour la progression d'un vire-langue specifique
final progressionProvider = Provider.family<Progression?, String>((ref, vireLangueId) {
  final progressions = ref.watch(progressionsProvider);
  return progressions.firstWhere(
    (p) => p.vireLangueId == vireLangueId,
    orElse: () => null,
  );
});

// Notifier pour gerer les progressions
class ProgressionNotifier extends StateNotifier<List<Progression>> {
  final Box<Progression> _box;
  
  ProgressionNotifier(this._box) : super(_box.values.toList());

  // Ajouter une progression
  void add(Progression progression) {
    _box.put(progression.id, progression);
    state = _box.values.toList();
  }

  // Mettre a jour une progression
  void update(Progression progression) {
    _box.put(progression.id, progression);
    state = _box.values.toList();
  }

  // Supprimer une progression
  void delete(String id) {
    _box.delete(id);
    state = _box.values.toList();
  }

  // Obtenir une progression par ID
  Progression? getById(String id) {
    return _box.get(id);
  }

  // Obtenir la progression pour un vire-langue
  Progression? getByVireLangueId(String vireLangueId) {
    return state.firstWhere(
      (p) => p.vireLangueId == vireLangueId,
      orElse: () => null,
    );
  }

  // Creer ou mettre a jour la progression pour un vire-langue
  Progression createOrUpdate({
    required String vireLangueId,
    int? nombreRepetitions,
    DateTime? dernierePratique,
    DateTime? prochainePratique,
    int? score,
    bool? maitrise,
  }) {
    final existing = getByVireLangueId(vireLangueId);
    
    if (existing != null) {
      final updated = existing.copyWith(
        nombreRepetitions: nombreRepetitions ?? existing.nombreRepetitions + 1,
        dernierePratique: dernierePratique ?? DateTime.now(),
        prochainePratique: prochainePratique,
        score: score ?? existing.score,
        maitrise: maitrise ?? existing.maitrise,
      );
      update(updated);
      return updated;
    } else {
      final id = const Uuid().v4();
      final progression = Progression(
        id: id,
        vireLangueId: vireLangueId,
        nombreRepetitions: nombreRepetitions ?? 1,
        dernierePratique: dernierePratique ?? DateTime.now(),
        prochainePratique: prochainePratique,
        score: score ?? 0,
        maitrise: maitrise ?? false,
      );
      add(progression);
      return progression;
    }
  }

  // Incrementer le compteur de repetitions
  void incrementRepetitions(String vireLangueId) {
    final progression = getByVireLangueId(vireLangueId);
    if (progression != null) {
      update(progression.copyWith(
        nombreRepetitions: progression.nombreRepetitions + 1,
        dernierePratique: DateTime.now(),
      ));
    } else {
      createOrUpdate(vireLangueId: vireLangueId);
    }
  }

  // Mettre a jour le score
  void updateScore(String vireLangueId, int newScore) {
    final progression = getByVireLangueId(vireLangueId);
    if (progression != null) {
      update(progression.copyWith(
        score: newScore,
        maitrise: newScore >= 90,
      ));
    } else {
      createOrUpdate(
        vireLangueId: vireLangueId,
        score: newScore,
        maitrise: newScore >= 90,
      );
    }
  }

  // Marquer comme maitrise
  void markAsMastered(String vireLangueId) {
    final progression = getByVireLangueId(vireLangueId);
    if (progression != null) {
      update(progression.copyWith(
        maitrise: true,
        score: 100,
      ));
    } else {
      createOrUpdate(
        vireLangueId: vireLangueId,
        maitrise: true,
        score: 100,
      );
    }
  }

  // Obtenir les statistiques globales
  Map<String, dynamic> getStatistics() {
    final total = state.length;
    final maitrises = state.where((p) => p.maitrise).length;
    final scoreMoyen = total > 0 
        ? state.fold(0, (sum, p) => sum + p.score) / total 
        : 0;
    
    return {
      'total': total,
      'maitrises': maitrises,
      'scoreMoyen': scoreMoyen.round(),
      'pourcentageMaîtrise': total > 0 ? (maitrises / total * 100).round() : 0,
    };
  }

  // Obtenir les vire-langues les plus pratiques
  List<Progression> getMostPracticed(int limit) {
    return [...state]
      ..sort((a, b) => b.nombreRepetitions.compareTo(a.nombreRepetitions))
      ..take(limit);
  }

  // Obtenir les vire-langues les mieux notes
  List<Progression> getHighestRated(int limit) {
    return [...state]
      ..sort((a, b) => b.score.compareTo(a.score))
      ..take(limit);
  }

  // Obtenir le streak actuel (nombre de jours consecutifs de pratique)
  int getCurrentStreak() {
    if (state.isEmpty) return 0;
    
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    
    // Verifier si au moins un vire-langue a ete pratique aujourd'hui
    final pratiqueAujourdhui = state.any((p) => 
      p.dernierePratique.year == now.year &&
      p.dernierePratique.month == now.month &&
      p.dernierePratique.day == now.day
    );
    
    if (!pratiqueAujourdhui) return 0;
    
    // Verifier hier
    final pratiqueHier = state.any((p) => 
      p.dernierePratique.year == yesterday.year &&
      p.dernierePratique.month == yesterday.month &&
      p.dernierePratique.day == yesterday.day
    );
    
    if (!pratiqueHier) return 1;
    
    // Continuer a remonter
    int streak = 2;
    DateTime current = yesterday.subtract(const Duration(days: 1));
    
    while (true) {
      final pratique = state.any((p) => 
        p.dernierePratique.year == current.year &&
        p.dernierePratique.month == current.month &&
        p.dernierePratique.day == current.day
      );
      
      if (!pratique) break;
      
      streak++;
      current = current.subtract(const Duration(days: 1));
    }
    
    return streak;
  }
}

// Provider pour le notifier
final progressionNotifierProvider = StateNotifierProvider<ProgressionNotifier, List<Progression>>((ref) {
  final box = ref.watch(progressionBoxProvider);
  return ProgressionNotifier(box);
});
