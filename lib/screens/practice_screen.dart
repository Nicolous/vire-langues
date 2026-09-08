import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vire_langues/models/vire_langue.dart';
import 'package:vire_langues/models/serie.dart';
import 'package:vire_langues/providers/providers.dart';
import 'package:vire_langues/theme/app_theme.dart';
import 'package:vire_langues/widgets/star_rating.dart';

class PracticeScreen extends ConsumerStatefulWidget {
  final VireLangue vireLangue;
  final Serie? serie;

  const PracticeScreen({
    super.key,
    required this.vireLangue,
    this.serie,
  });

  @override
  ConsumerState<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends ConsumerState<PracticeScreen> {
  int _repetitions = 0;
  int _score = 0;
  bool _isPracticing = false;
  DateTime? _startTime;
  DateTime? _endTime;
  final List<DateTime> _attemptTimes = [];
  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Obtenir la progression existante
    final progression = ref.read(progressionProvider(widget.vireLangue.id));
    if (progression != null) {
      _repetitions = progression.nombreRepetitions;
      _score = progression.score;
    }
  }

  @override
  Widget build(BuildContext context) {
    final progression = ref.watch(progressionProvider(widget.vireLangue.id));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.vireLangue.texte.length > 20
            ? widget.vireLangue.texte.substring(0, 17) + '...'
            : widget.vireLangue.texte),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // En-tête avec le vire-langue
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      widget.vireLangue.texte,
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Chip(
                          label: Text(widget.vireLangue.categorie),
                          backgroundColor: Colors.grey[200],
                        ),
                        const SizedBox(width: 8),
                        Chip(
                          label: Text(widget.vireLangue.difficulteLibelle),
                          backgroundColor: widget.vireLangue.difficulteCouleur.withOpacity(0.2),
                          labelStyle: TextStyle(color: widget.vireLangue.difficulteCouleur),
                        ),
                      ],
                    ),
                    if (widget.serie != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Série: ${widget.serie!.nom}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Section de pratique
            if (!_isPracticing) ...[
              _buildPrePracticeSection(progression),
            ] else ...[
              _buildDuringPracticeSection(),
            ],

            // Statistiques
            const SizedBox(height: 24),
            _buildStatsSection(progression),
          ],
        ),
      ),
    );
  }

  Widget _buildPrePracticeSection(Progression? progression) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Mode de Pratique',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Progression actuelle
            if (progression != null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Votre niveau: ',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  StarRating(
                    rating: progression.niveau,
                    color: progression.niveauCouleur,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${progression.score}%',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Répétitions: ${progression.nombreRepetitions}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
            ],

            // Boutons de pratique
            ElevatedButton.icon(
              onPressed: () => _startPractice(),
              icon: const Icon(Icons.play_arrow),
              label: const Text('Commencer la pratique'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => _startTimedPractice(),
              icon: const Icon(Icons.timer),
              label: const Text('Pratique chronométrée'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDuringPracticeSection() {
    final elapsedTime = _startTime != null 
        ? DateTime.now().difference(_startTime!)
        : Duration.zero;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'En Pratique',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            
            // Chronomètre
            Text(
              _formatDuration(elapsedTime),
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Répétitions: $_repetitions',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 24),
            
            // Vire-langue à répéter
            Text(
              widget.vireLangue.texte,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            
            // Boutons d'action
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton.filled(
                  onPressed: () {
                    setState(() {
                      _repetitions++;
                      _attemptTimes.add(DateTime.now());
                    });
                  },
                  icon: const Icon(Icons.add),
                  tooltip: 'Compter une répétition',
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                IconButton.filled(
                  onPressed: () => _endPractice(),
                  icon: const Icon(Icons.stop),
                  tooltip: 'Terminer',
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection(Progression? progression) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Statistiques',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Stats globales
            Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: [
                _buildStatItem('Niveau', progression?.niveau.toString() ?? '0', Icons.star),
                _buildStatItem('Score', '${progression?.score ?? 0}%', Icons.analytics),
                _buildStatItem('Répétitions', progression?.nombreRepetitions.toString() ?? '0', Icons.repeat),
                if (_startTime != null && _endTime != null) ...[
                  _buildStatItem('Temps', _formatDuration(_endTime!.difference(_startTime!)), Icons.timer),
                ],
              ],
            ),
            const SizedBox(height: 16),
            
            // Note personnelle
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: 'Note personnelle',
                hintText: 'Ajoutez une note sur votre progression...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            
            // Evaluation
            Text(
              'Évaluez votre performance',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            StarRating(
              rating: _score ~/ 20, // Convertir le score (0-100) en étoiles (0-5)
              color: AppColors.warning,
              size: 32,
              onRatingChanged: (rating) {
                setState(() {
                  _score = rating * 20;
                });
              },
            ),
            const SizedBox(height: 16),
            
            // Bouton d'enregistrement
            ElevatedButton.icon(
              onPressed: () => _saveProgress(),
              icon: const Icon(Icons.save),
              label: const Text('Enregistrer la progression'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 24, color: AppColors.primary),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  void _startPractice() {
    setState(() {
      _isPracticing = true;
      _startTime = DateTime.now();
      _endTime = null;
      _attemptTimes.clear();
    });
  }

  void _startTimedPractice() {
    setState(() {
      _isPracticing = true;
      _startTime = DateTime.now();
      _endTime = null;
      _attemptTimes.clear();
      _repetitions = 0;
    });
    
    // Démarrer un minuteur pour rappeler à l'utilisateur
    Future.delayed(const Duration(minutes: 1), () {
      if (mounted && _isPracticing) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Continuez à pratiquer !'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    });
  }

  void _endPractice() {
    setState(() {
      _isPracticing = false;
      _endTime = DateTime.now();
    });
  }

  void _saveProgress() {
    // Mettre à jour la progression
    ref.read(progressionNotifierProvider.notifier).createOrUpdate(
      vireLangueId: widget.vireLangue.id,
      nombreRepetitions: _repetitions,
      score: _score,
      maîtrisé: _score >= 90,
    );

    // Afficher un message de confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Progression enregistrée: $_score%'),
        backgroundColor: AppColors.success,
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {},
        ),
      ),
    );

    // Retourner à l'écran précédent
    Navigator.pop(context);
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    final milliseconds = duration.inMilliseconds % 1000;
    
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}.${(milliseconds ~/ 10).toString().padLeft(2, '0')}';
  }
}
