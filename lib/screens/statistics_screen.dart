import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vire_langues/models/vire_langue.dart';
import 'package:vire_langues/providers/providers.dart';
import 'package:vire_langues/theme/app_theme.dart';
import 'package:vire_langues/widgets/stat_card.dart';
import 'package:vire_langues/widgets/star_rating.dart';

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressionNotifier = ref.watch(progressionNotifierProvider.notifier);
    final stats = progressionNotifier.getStatistics();
    final progressions = ref.watch(progressionsProvider);
    final vireLangues = ref.watch(vireLanguesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistiques'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Statistiques globales
            _buildGlobalStats(stats),
            const SizedBox(height: 24),

            // Streak
            _buildStreakCard(progressionNotifier),
            const SizedBox(height: 24),

            // Répartition par difficulté
            _buildDifficultyDistribution(vireLangues, progressions),
            const SizedBox(height: 24),

            // Meilleurs vire-langues
            _buildTopVireLangues(progressionNotifier, vireLangues),
            const SizedBox(height: 24),

            // Historique
            _buildHistory(progressions, vireLangues),
          ],
        ),
      ),
    );
  }

  Widget _buildGlobalStats(Map<String, dynamic> stats) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Statistiques Globales',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                StatCard(
                  value: stats['total']?.toString() ?? '0',
                  label: 'Total Pratiqués',
                  icon: Icons.format_list_numbered,
                  color: AppColors.primary,
                ),
                StatCard(
                  value: stats['maîtrisés']?.toString() ?? '0',
                  label: 'Maîtrisés',
                  icon: Icons.star,
                  color: AppColors.success,
                ),
                StatCard(
                  value: '${stats['scoreMoyen']?.toString() ?? '0'}%',
                  label: 'Score Moyen',
                  icon: Icons.analytics,
                  color: AppColors.info,
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: (stats['pourcentageMaîtrisé'] ?? 0) / 100,
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.success),
            ),
            const SizedBox(height: 8),
            Text(
              'Progression globale: ${stats['pourcentageMaîtrisé']?.round() ?? 0}%',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakCard(ProgressionNotifier notifier) {
    final streak = notifier.getCurrentStreak();
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.whatshot,
              size: 48,
              color: streak > 0 ? AppColors.success : Colors.grey,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Streak Actuel',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    '$streak jour${streak > 1 ? 's' : ''} de pratique consécutifs',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: streak > 0 ? AppColors.success : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            if (streak > 0) ...[
              Icon(
                Icons.celebration,
                size: 32,
                color: AppColors.warning,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultyDistribution(List<VireLangue> vireLangues, List<dynamic> progressions) {
    final easyCount = vireLangues.where((vl) => vl.difficulte == VireLangue.facile).length;
    final mediumCount = vireLangues.where((vl) => vl.difficulte == VireLangue.moyen).length;
    final hardCount = vireLangues.where((vl) => vl.difficulte == VireLangue.difficile).length;

    final easyMastered = progressions
        .where((p) => p.maîtrisé)
        .where((p) {
          final vl = vireLangues.firstWhere((v) => v.id == p.vireLangueId, orElse: () => null);
          return vl != null && vl.difficulte == VireLangue.facile;
        })
        .length;

    final mediumMastered = progressions
        .where((p) => p.maîtrisé)
        .where((p) {
          final vl = vireLangues.firstWhere((v) => v.id == p.vireLangueId, orElse: () => null);
          return vl != null && vl.difficulte == VireLangue.moyen;
        })
        .length;

    final hardMastered = progressions
        .where((p) => p.maîtrisé)
        .where((p) {
          final vl = vireLangues.firstWhere((v) => v.id == p.vireLangueId, orElse: () => null);
          return vl != null && vl.difficulte == VireLangue.difficile;
        })
        .length;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Répartition par Difficulté',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Facile
            _buildDifficultyRow(
              'Facile',
              easyCount,
              easyMastered,
              Colors.green,
            ),
            const SizedBox(height: 8),
            
            // Moyen
            _buildDifficultyRow(
              'Moyen',
              mediumCount,
              mediumMastered,
              Colors.orange,
            ),
            const SizedBox(height: 8),
            
            // Difficile
            _buildDifficultyRow(
              'Difficile',
              hardCount,
              hardMastered,
              Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultyRow(String label, int total, int mastered, Color color) {
    final percentage = total > 0 ? (mastered / total * 100).round() : 0;
    
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$mastered/$total (${percentage}%)',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildTopVireLangues(ProgressionNotifier notifier, List<VireLangue> vireLangues) {
    final topPracticed = notifier.getMostPracticed(5);
    final topRated = notifier.getHighestRated(5);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Les plus pratiqués
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Les plus Pratiqués',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...topPracticed.map((p) {
                  final vl = vireLangues.firstWhere((v) => v.id == p.vireLangueId, orElse: () => null);
                  if (vl == null) return const SizedBox.shrink();
                  
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(vl.texte),
                      subtitle: Row(
                        children: [
                          Chip(
                            label: Text(vl.categorie),
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          const SizedBox(width: 4),
                          Chip(
                            label: Text(vl.difficulteLibelle),
                            backgroundColor: vl.difficulteCouleur.withOpacity(0.2),
                            labelStyle: TextStyle(color: vl.difficulteCouleur),
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ],
                      ),
                      trailing: Text('${p.nombreRepetitions}x'),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // Les mieux notés
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Les mieux Notés',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...topRated.map((p) {
                  final vl = vireLangues.firstWhere((v) => v.id == p.vireLangueId, orElse: () => null);
                  if (vl == null) return const SizedBox.shrink();
                  
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(vl.texte),
                      subtitle: Row(
                        children: [
                          StarRating(
                            rating: p.niveau,
                            color: p.niveauCouleur,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text('${p.score}%'),
                        ],
                      ),
                      trailing: p.maîtrisé 
                          ? Icon(Icons.check_circle, color: AppColors.success)
                          : null,
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHistory(List<dynamic> progressions, List<VireLangue> vireLangues) {
    if (progressions.isEmpty) {
      return Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(
                Icons.history,
                size: 48,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              Text(
                'Aucun historique de pratique',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Commencez à pratiquer pour voir votre historique.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // Trier par date de dernière pratique (les plus récents en premier)
    final sortedProgressions = [...progressions]
      ..sort((a, b) => b.dernièrePratique.compareTo(a.dernièrePratique));

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Historique Récent',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...sortedProgressions.take(10).map((p) {
              final vl = vireLangues.firstWhere((v) => v.id == p.vireLangueId, orElse: () => null);
              if (vl == null) return const SizedBox.shrink();
              
              final date = p.dernièrePratique;
              final formattedDate = '${date.day}/${date.month}/${date.year}';

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(vl.texte),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('$formattedDate - ${p.nombreRepetitions}x'),
                      StarRating(
                        rating: p.niveau,
                        color: p.niveauCouleur,
                        size: 14,
                      ),
                    ],
                  ),
                  trailing: Text('${p.score}%'),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
