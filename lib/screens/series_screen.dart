import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vire_langues/models/serie.dart';
import 'package:vire_langues/models/vire_langue.dart';
import 'package:vire_langues/providers/providers.dart';
import 'package:vire_langues/screens/practice_screen.dart';
import 'package:vire_langues/theme/app_theme.dart';
import 'package:vire_langues/widgets/serie_card.dart';
import 'package:vire_langues/widgets/vire_langue_card.dart';

class SeriesScreen extends ConsumerStatefulWidget {
  final String? selectedCategory;
  
  const SeriesScreen({super.key, this.selectedCategory});

  @override
  ConsumerState<SeriesScreen> createState() => _SeriesScreenState();
}

class _SeriesScreenState extends ConsumerState<SeriesScreen> {
  @override
  Widget build(BuildContext context) {
    final series = ref.watch(seriesProvider);
    final vireLangues = ref.watch(vireLanguesProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Series'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreateSerieDialog(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Filtre par categorie si selectionne
            if (widget.selectedCategory != null) ...[
              Chip(
                label: Text('Categorie: ${widget.selectedCategory}'),
                onDeleted: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SeriesScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
            
            // Series par defaut
            if (series.isNotEmpty) ...[
              Text(
                'Series par defaut',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...series.where((s) => !s.estPersonnalisee).map((serie) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: SerieCard(
                    serie: serie,
                    vireLangues: vireLangues,
                    onTap: () => _navigateToSerieDetail(serie),
                  ),
                );
              }).toList(),
              const SizedBox(height: 24),
            ],
            
            // Series personnalisees
            Text(
              'Vos Series Personnalisees',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            
            if (series.where((s) => s.estPersonnalisee).isEmpty) ...[
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.playlist_add,
                        size: 48,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Aucune serie personnalisee',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Creez votre première serie pour organiser vos vire-langues preferes.',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => _showCreateSerieDialog(context),
                        icon: const Icon(Icons.add),
                        label: const Text('Creer une serie'),
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              ...series.where((s) => s.estPersonnalisee).map((serie) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: SerieCard(
                    serie: serie,
                    vireLangues: vireLangues,
                    onTap: () => _navigateToSerieDetail(serie),
                    onDelete: () => _deleteSerie(serie),
                    onEdit: () => _showEditSerieDialog(context, serie),
                  ),
                );
              }).toList(),
            ],
          ],
        ),
      ),
    );
  }

  void _navigateToSerieDetail(Serie serie) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SerieDetailScreen(serie: serie),
      ),
    );
  }

  Future<void> _deleteSerie(Serie serie) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la serie'),
        content: Text('Êtes-vous sûr de vouloir supprimer "${serie.nom}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      ref.read(serieNotifierProvider.notifier).delete(serie.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Serie "${serie.nom}" supprimee'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Future<void> _showCreateSerieDialog(BuildContext context) async {
    final vireLangues = ref.read(vireLanguesProvider);
    final nomController = TextEditingController();
    final descriptionController = TextEditingController();
    final selectedVireLangues = <String>{};

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Creer une nouvelle serie'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nomController,
                  decoration: const InputDecoration(
                    labelText: 'Nom de la serie',
                    hintText: 'Ex: Mes favoris',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Description de la serie',
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                Text(
                  'Selectionnez les vire-langues',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 200,
                  child: ListView.builder(
                    itemCount: vireLangues.length,
                    itemBuilder: (context, index) {
                      final vl = vireLangues[index];
                      final isSelected = selectedVireLangues.contains(vl.id);
                      
                      return CheckboxListTile(
                        title: Text(vl.texte),
                        subtitle: Text('${vl.categorie} - ${vl.difficulteLibelle}'),
                        value: isSelected,
                        onChanged: (selected) {
                          setState(() {
                            if (selected == true) {
                              selectedVireLangues.add(vl.id);
                            } else {
                              selectedVireLangues.remove(vl.id);
                            }
                          });
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: selectedVireLangues.isEmpty
                  ? null
                  : () {
                      if (nomController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Veuillez entrer un nom pour la serie'),
                            backgroundColor: AppColors.error,
                          ),
                        );
                        return;
                      }

                      ref.read(serieNotifierProvider.notifier).create(
                        nom: nomController.text,
                        description: descriptionController.text,
                        vireLangueIds: selectedVireLangues.toList(),
                        estPersonnalisee: true,
                      );

                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Serie creee avec succès !'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    },
              child: const Text('Creer'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showEditSerieDialog(BuildContext context, Serie serie) async {
    final vireLangues = ref.read(vireLanguesProvider);
    final nomController = TextEditingController(text: serie.nom);
    final descriptionController = TextEditingController(text: serie.description);
    final selectedVireLangues = serie.vireLangueIds.toSet();

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Modifier la serie'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nomController,
                  decoration: const InputDecoration(
                    labelText: 'Nom de la serie',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                Text(
                  'Selectionnez les vire-langues',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 200,
                  child: ListView.builder(
                    itemCount: vireLangues.length,
                    itemBuilder: (context, index) {
                      final vl = vireLangues[index];
                      final isSelected = selectedVireLangues.contains(vl.id);
                      
                      return CheckboxListTile(
                        title: Text(vl.texte),
                        subtitle: Text('${vl.categorie} - ${vl.difficulteLibelle}'),
                        value: isSelected,
                        onChanged: (selected) {
                          setState(() {
                            if (selected == true) {
                              selectedVireLangues.add(vl.id);
                            } else {
                              selectedVireLangues.remove(vl.id);
                            }
                          });
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: selectedVireLangues.isEmpty || nomController.text.isEmpty
                  ? null
                  : () {
                      ref.read(serieNotifierProvider.notifier).update(
                        serie.copyWith(
                          nom: nomController.text,
                          description: descriptionController.text,
                          vireLangueIds: selectedVireLangues.toList(),
                        ),
                      );

                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Serie modifiee avec succès !'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    },
              child: const Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );
  }
}

class SerieDetailScreen extends ConsumerStatefulWidget {
  final Serie serie;
  
  const SerieDetailScreen({super.key, required this.serie});

  @override
  ConsumerState<SerieDetailScreen> createState() => _SerieDetailScreenState();
}

class _SerieDetailScreenState extends ConsumerState<SerieDetailScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final vireLangues = ref.watch(vireLanguesProvider);
    final serieVireLangues = widget.serie.vireLangueIds
        .map((id) => vireLangues.firstWhere((vl) => vl.id == id))
        .where((vl) => vl != null)
        .cast<VireLangue>()
        .toList();

    if (serieVireLangues.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.serie.nom),
        ),
        body: Center(
          child: Text(
            'Aucun vire-langue dans cette serie',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
      );
    }

    final currentVireLangue = serieVireLangues[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.serie.nom),
        actions: [
          IconButton(
            icon: const Icon(Icons.shuffle),
            onPressed: () {
              setState(() {
                _currentIndex = DateTime.now().millisecondsSinceEpoch % serieVireLangues.length;
              });
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Progression dans la serie
            LinearProgressIndicator(
              value: (_currentIndex + 1) / serieVireLangues.length,
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
            const SizedBox(height: 8),
            Text(
              'Vire-langue ${_currentIndex + 1} / ${serieVireLangues.length}',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Vire-langue actuel
            VireLangueCard(
              vireLangue: currentVireLangue,
              progression: ref.watch(progressionProvider(currentVireLangue.id)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PracticeScreen(
                      vireLangue: currentVireLangue,
                      serie: widget.serie,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // Navigation
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: _currentIndex > 0
                      ? () => setState(() => _currentIndex--)
                      : null,
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: _currentIndex < serieVireLangues.length - 1
                      ? () => setState(() => _currentIndex++)
                      : null,
                ),
              ],
            ),

            // Liste des vire-langues de la serie
            const SizedBox(height: 24),
            Text(
              'Tous les vire-langues de cette serie',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: serieVireLangues.length,
                itemBuilder: (context, index) {
                  final vl = serieVireLangues[index];
                  final progression = ref.watch(progressionProvider(vl.id));
                  
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    elevation: _currentIndex == index ? 4 : 1,
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
                      trailing: progression != null
                          ? Icon(
                              Icons.star,
                              color: progression.niveauCouleur,
                              size: 20,
                            )
                          : null,
                      selected: _currentIndex == index,
                      selectedTileColor: AppColors.primary.withOpacity(0.1),
                      onTap: () => setState(() => _currentIndex = index),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PracticeScreen(
                vireLangue: currentVireLangue,
                serie: widget.serie,
              ),
            ),
          );
        },
        child: const Icon(Icons.play_arrow),
      ),
    );
  }
}
