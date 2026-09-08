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

// Provider pour la progression d'un vire-langue spécifique
final progressionProvider = Provider.family<Progression?, String>((ref, vireLangueId) {
  final progressions = ref.watch(progressionsProvider);
  return progressions.firstWhere(
    (p) => p.vireLangueId == vireLangueId,
    orElse: () => null,
  );
});

// Notifier pour gérer les progressions
class ProgressionNotifier extends StateNotifier<List<Progression>> {
  final Box<Progression> _box;
  
  ProgressionNotifier(this._box) : super(_box.values.toList());

  // Ajouter une progression
  void add(Progression progression) {
    _box.put(progression.id, progression);
    state = _box.values.toList();
  }

  // Mettre à jour une progression
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

  // Créer ou mettre à jour la progression pour un vire-langue
  Progression createOrUpdate({
    required String vireLangueId,
    int? nombreRepetitions,
    DateTime? dernièrePratique,
    DateTime? prochainePratique,
    int? score,
    bool? maîtrisé,
  }) {
    final existing = getByVireLangueId(vireLangueId);
    
    if (existing != null) {
      final updated = existing.copyWith(
        nombreRepetitions: nombreRepetitions ?? existing.nombreRepetitions + 1,
        dernièrePratique: dernièrePratique ?? DateTime.now(),
        prochainePratique: prochainePratique,
        score: score ?? existing.score,
        maîtrisé: maîtrisé ?? existing.maîtrisé,
      );
      update(updated);
      return updated;
    } else {
      final id = const Uuid().v4();
      final progression = Progression(
        id: id,
        vireLangueId: vireLangueId,
        nombreRepetitions: nombreRepetitions ?? 1,
        dernièrePratique: dernièrePratique ?? DateTime.now(),
        prochainePratique: prochainePratique,
        score: score ?? 0,
        maîtrisé: maîtrisé ?? false,
      );
      add(progression);
      return progression;
    }
  }

  // Incrémenter le compteur de répétitions
  void incrementRepetitions(String vireLangueId) {
    final progression = getByVireLangueId(vireLangueId);
    if (progression != null) {
      update(progression.copyWith(
        nombreRepetitions: progression.nombreRepetitions + 1,
        dernièrePratique: DateTime.now(),
      ));
    } else {
      createOrUpdate(vireLangueId: vireLangueId);
    }
  }

  // Mettre à jour le score
  void updateScore(String vireLangueId, int newScore) {
    final progression = getByVireLangueId(vireLangueId);
    if (progression != null) {
      update(progression.copyWith(
        score: newScore,
        maîtrisé: newScore >= 90,
      ));
    } else {
      createOrUpdate(
        vireLangueId: vireLangueId,
        score: newScore,
        maîtrisé: newScore >= 90,
      );
    }
  }

  // Marquer comme maîtrisé
  void markAsMastered(String vireLangueId) {
    final progression = getByVireLangueId(vireLangueId);
    if (progression != null) {
      update(progression.copyWith(
        maîtrisé: true,
        score: 100,
      ));
    } else {
      createOrUpdate(
        vireLangueId: vireLangueId,
        maîtrisé: true,
        score: 100,
      );
    }
  }

  // Obtenir les statistiques globales
  Map<String, dynamic> getStatistics() {
    final total = state.length;
    final maîtrisés = state.where((p) => p.maîtrisé).length;
    final scoreMoyen = total > 0 
        ? state.fold(0, (sum, p) => sum + p.score) / total 
        : 0;
    
    return {
      'total': total,
      'maîtrisés': maîtrisés,
      'scoreMoyen': scoreMoyen.round(),
      'pourcentageMaîtrisé': total > 0 ? (maîtrisés / total * 100).round() : 0,
    };
  }

  // Obtenir les vire-langues les plus pratiqués
  List<Progression> getMostPracticed(int limit) {
    return [...state]
      ..sort((a, b) => b.nombreRepetitions.compareTo(a.nombreRepetitions))
      ..take(limit);
  }

  // Obtenir les vire-langues les mieux notés
  List<Progression> getHighestRated(int limit) {
    return [...state]
      ..sort((a, b) => b.score.compareTo(a.score))
      ..take(limit);
  }

  // Obtenir le streak actuel (nombre de jours consécutifs de pratique)
  int getCurrentStreak() {
    if (state.isEmpty) return 0;
    
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    
    // Vérifier si au moins un vire-langue a été pratiqué aujourd'hui
    final pratiquéAujourdhui = state.any((p) => 
      p.dernièrePratique.year == now.year &&
      p.dernièrePratique.month == now.month &&
      p.dernièrePratique.day == now.day
    );
    
    if (!pratiquéAujourdhui) return 0;
    
    // Vérifier hier
    final pratiquéHier = state.any((p) => 
      p.dernièrePratique.year == yesterday.year &&
      p.dernièrePratique.month == yesterday.month &&
      p.dernièrePratique.day == yesterday.day
    );
    
    if (!pratiquéHier) return 1;
    
    // Continuer à remonter
    int streak = 2;
    DateTime current = yesterday.subtract(const Duration(days: 1));
    
    while (true) {
      final pratiqué = state.any((p) => 
        p.dernièrePratique.year == current.year &&
        p.dernièrePratique.month == current.month &&
        p.dernièrePratique.day == current.day
      );
      
      if (!pratiqué) break;
      
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
