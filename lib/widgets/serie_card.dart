import 'package:flutter/material.dart';
import 'package:vire_langues/models/serie.dart';
import 'package:vire_langues/models/vire_langue.dart';
import 'package:vire_langues/theme/app_theme.dart';

class SerieCard extends StatelessWidget {
  final Serie serie;
  final List<VireLangue> vireLangues;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;

  const SerieCard({
    super.key,
    required this.serie,
    required this.vireLangues,
    this.onTap,
    this.onDelete,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    // Obtenir les vire-langues de la serie
    final serieVireLangues = serie.vireLangueIds
        .map((id) => vireLangues.firstWhere((vl) => vl.id == id))
        .where((vl) => vl != null)
        .cast<VireLangue>()
        .toList();

    // Calculer la difficulte moyenne
    final avgDifficulty = serieVireLangues.isNotEmpty
        ? serieVireLangues.fold(0, (sum, vl) => sum + vl.difficulte) / serieVireLangues.length
        : 0;

    // Calculer le nombre de vire-langues maitrises
    final masteredCount = 0; // TODO: Implementer avec les donnees de progression

    return Card(
      elevation: 2,
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
              // En-tête
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          serie.nom,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          serie.description,
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (serie.estPersonnalisee && (onDelete != null || onEdit != null)) ...[
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        switch (value) {
                          case 'edit':
                            onEdit?.call();
                            break;
                          case 'delete':
                            onDelete?.call();
                            break;
                        }
                      },
                      itemBuilder: (context) => [
                        if (onEdit != null)
                          const PopupMenuItem<String>(
                            value: 'edit',
                            child: ListTile(
                              leading: Icon(Icons.edit),
                              title: Text('Modifier'),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        if (onDelete != null)
                          const PopupMenuItem<String>(
                            value: 'delete',
                            child: ListTile(
                              leading: Icon(Icons.delete, color: Colors.red),
                              title: Text('Supprimer', style: TextStyle(color: Colors.red)),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),
              
              // Statistiques
              Row(
                children: [
                  _buildStatItem(
                    context,
                    '${serieVireLangues.length}',
                    'Vire-langues',
                    Icons.format_list_numbered,
                    AppColors.primary,
                  ),
                  const SizedBox(width: 16),
                  _buildStatItem(
                    context,
                    _getDifficultyLabel(avgDifficulty),
                    'Difficulte moyenne',
                    Icons.trending_up,
                    _getDifficultyColor(avgDifficulty),
                  ),
                  const SizedBox(width: 16),
                  _buildStatItem(
                    context,
                    '$masteredCount',
                    'Maîtrises',
                    Icons.star,
                    AppColors.success,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Indicateur de type de serie
              if (serie.estPersonnalisee) ...[
                Chip(
                  label: const Text('Personnalisee'),
                  backgroundColor: AppColors.secondary.withOpacity(0.2),
                  labelStyle: const TextStyle(color: AppColors.secondary),
                  avatar: const Icon(Icons.person, color: AppColors.secondary, size: 16),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  String _getDifficultyLabel(double avgDifficulty) {
    if (avgDifficulty <= 1.5) return 'Facile';
    if (avgDifficulty <= 2.5) return 'Moyen';
    return 'Difficile';
  }

  Color _getDifficultyColor(double avgDifficulty) {
    if (avgDifficulty <= 1.5) return Colors.green;
    if (avgDifficulty <= 2.5) return Colors.orange;
    return Colors.red;
  }
}
