import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vire_langues/models/vire_langue.dart';
import 'package:vire_langues/models/serie.dart';
import 'package:vire_langues/providers/providers.dart';
import 'package:vire_langues/screens/practice_screen.dart';
import 'package:vire_langues/screens/series_screen.dart';
import 'package:vire_langues/screens/settings_screen.dart';
import 'package:vire_langues/screens/statistics_screen.dart';
import 'package:vire_langues/theme/app_theme.dart';
import 'package:vire_langues/widgets/vire_langue_card.dart';
import 'package:vire_langues/widgets/stat_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final progressionNotifier = ref.watch(progressionNotifierProvider.notifier);
    final stats = progressionNotifier.getStatistics();
    final vireLangues = ref.watch(vireLanguesProvider);
    final series = ref.watch(seriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vire-Langues'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.refresh(vireLanguesProvider);
              ref.refresh(seriesProvider);
              ref.refresh(progressionsProvider);
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: _buildBody(_currentIndex, stats, vireLangues, series),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.format_list_numbered),
            label: 'Series',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Stats',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Naviguer vers la pratique avec un vire-langue aleatoire
          final randomVireLangue = ref.read(vireLangueNotifierProvider.notifier).getRandom();
          if (randomVireLangue != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PracticeScreen(
                  vireLangue: randomVireLangue,
                  serie: null,
                ),
              ),
            );
          }
        },
        child: const Icon(Icons.play_arrow),
      ),
    );
  }

  Widget _buildBody(int index, Map<String, dynamic> stats, List<VireLangue> vireLangues, List<Serie> series) {
    switch (index) {
      case 0:
        return _buildHomeContent(stats, vireLangues);
      case 1:
        return const SeriesScreen();
      case 2:
        return const StatisticsScreen();
      default:
        return _buildHomeContent(stats, vireLangues);
    }
  }

  Widget _buildHomeContent(Map<String, dynamic> stats, List<VireLangue> vireLangues) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Statistiques
          _buildStatsSection(stats),
          const SizedBox(height: 24),

          // Vire-langue du jour
          _buildVireLangueDuJour(vireLangues),
          const SizedBox(height: 24),

          // Derniers pratiques
          _buildDerniersPratiques(),
          const SizedBox(height: 24),

          // Categories
          _buildCategoriesSection(),
        ],
      ),
    );
  }

  Widget _buildStatsSection(Map<String, dynamic> stats) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Votre Progression',
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
                  label: 'Total',
                  icon: Icons.format_list_numbered,
                  color: AppColors.primary,
                ),
                StatCard(
                  value: stats['maitrises']?.toString() ?? '0',
                  label: 'Maîtrises',
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
              value: (stats['pourcentageMaîtrise'] ?? 0) / 100,
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.success),
            ),
            const SizedBox(height: 8),
            Text(
              'Progression globale: ${stats['pourcentageMaîtrise']?.round() ?? 0}%',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVireLangueDuJour(List<VireLangue> vireLangues) {
    if (vireLangues.isEmpty) {
      return const SizedBox.shrink();
    }

    // Obtenir un vire-langue aleatoire pour aujourd'hui
    final today = DateTime.now();
    final seed = today.year * 365 + today.month * 30 + today.day;
    final index = seed % vireLangues.length;
    final vireLangueDuJour = vireLangues[index];

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  Icons.today,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Vire-Langue du Jour',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              vireLangueDuJour.texte,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w500,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Chip(
                  label: Text(vireLangueDuJour.categorie),
                  backgroundColor: Colors.grey[200],
                ),
                const SizedBox(width: 8),
                Chip(
                  label: Text(vireLangueDuJour.difficulteLibelle),
                  backgroundColor: vireLangueDuJour.difficulteCouleur.withOpacity(0.2),
                  labelStyle: TextStyle(color: vireLangueDuJour.difficulteCouleur),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PracticeScreen(
                      vireLangue: vireLangueDuJour,
                      serie: null,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text('Pratiquer'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDerniersPratiques() {
    final progressions = ref.watch(progressionsProvider);
    
    if (progressions.isEmpty) {
      return const SizedBox.shrink();
    }

    // Trier par date de derniere pratique (les plus recents en premier)
    final sortedProgressions = [...progressions]
      ..sort((a, b) => b.dernierePratique.compareTo(a.dernierePratique));

    final recentProgressions = sortedProgressions.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Derniers Pratiques',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...recentProgressions.map((progression) {
          final vireLangue = ref.read(vireLangueNotifierProvider.notifier).getById(progression.vireLangueId);
          if (vireLangue == null) return const SizedBox.shrink();
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: VireLangueCard(
              vireLangue: vireLangue,
              progression: progression,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PracticeScreen(
                      vireLangue: vireLangue,
                      serie: null,
                    ),
                  ),
                );
              },
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildCategoriesSection() {
    final vireLangues = ref.watch(vireLanguesProvider);
    final categories = VireLangue.categories;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Categories',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: categories.map((category) {
            final count = vireLangues.where((vl) => vl.categorie == category).length;
            return FilterChip(
              label: Text('$category ($count)'),
              onSelected: (selected) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SeriesScreen(
                      selectedCategory: selected ? category : null,
                    ),
                  ),
                );
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}
