import 'package:flutter/material.dart';
import 'package:vire_langues/models/vire_langue.dart';
import 'package:vire_langues/models/progression.dart';
import 'package:vire_langues/theme/app_theme.dart';
import 'package:vire_langues/widgets/star_rating.dart';

class VireLangueCard extends StatelessWidget {
  final VireLangue vireLangue;
  final Progression? progression;
  final VoidCallback? onTap;

  const VireLangueCard({
    super.key,
    required this.vireLangue,
    this.progression,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Texte du vire-langue
              Text(
                vireLangue.texte,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              
              // Catégorie et difficulté
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Chip(
                    label: Text(vireLangue.categorie),
                    backgroundColor: Colors.grey[200],
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  const SizedBox(width: 8),
                  Chip(
                    label: Text(vireLangue.difficulteLibelle),
                    backgroundColor: vireLangue.difficulteCouleur.withOpacity(0.2),
                    labelStyle: TextStyle(color: vireLangue.difficulteCouleur),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Progression
              if (progression != null) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    StarRating(
                      rating: progression.niveau,
                      color: progression.niveauCouleur,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${progression.score}%',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${progression.nombreRepetitions}x',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
                // Indicateur de maîtrise
                if (progression.maîtrisé) ...[
                  Chip(
                    label: const Text('Maîtrisé'),
                    backgroundColor: AppColors.success.withOpacity(0.2),
                    labelStyle: const TextStyle(color: AppColors.success),
                    avatar: const Icon(Icons.check_circle, color: AppColors.success, size: 16),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}
