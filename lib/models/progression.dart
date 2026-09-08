import 'package:hive/hive.dart';

part 'progression.g.dart';

@HiveType(typeId: 2)
class Progression {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String vireLangueId;
  
  @HiveField(2)
  final int nombreRepetitions;
  
  @HiveField(3)
  final DateTime dernièrePratique;
  
  @HiveField(4)
  final DateTime? prochainePratique;
  
  @HiveField(5)
  final int score; // 0-100
  
  @HiveField(6)
  final bool maîtrisé;

  Progression({
    required this.id,
    required this.vireLangueId,
    this.nombreRepetitions = 0,
    DateTime? dernièrePratique,
    this.prochainePratique,
    this.score = 0,
    this.maîtrisé = false,
  }) : dernièrePratique = dernièrePratique ?? DateTime.now();

  Progression copyWith({
    String? id,
    String? vireLangueId,
    int? nombreRepetitions,
    DateTime? dernièrePratique,
    DateTime? prochainePratique,
    int? score,
    bool? maîtrisé,
  }) {
    return Progression(
      id: id ?? this.id,
      vireLangueId: vireLangueId ?? this.vireLangueId,
      nombreRepetitions: nombreRepetitions ?? this.nombreRepetitions,
      dernièrePratique: dernièrePratique ?? this.dernièrePratique,
      prochainePratique: prochainePratique ?? this.prochainePratique,
      score: score ?? this.score,
      maîtrisé: maîtrisé ?? this.maîtrisé,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vireLangueId': vireLangueId,
      'nombreRepetitions': nombreRepetitions,
      'dernièrePratique': dernièrePratique.toIso8601String(),
      'prochainePratique': prochainePratique?.toIso8601String(),
      'score': score,
      'maîtrisé': maîtrisé,
    };
  }

  factory Progression.fromMap(Map<String, dynamic> map) {
    return Progression(
      id: map['id'] ?? '',
      vireLangueId: map['vireLangueId'] ?? '',
      nombreRepetitions: map['nombreRepetitions'] ?? 0,
      dernièrePratique: DateTime.tryParse(map['dernièrePratique'] ?? '') ?? DateTime.now(),
      prochainePratique: DateTime.tryParse(map['prochainePratique'] ?? ''),
      score: map['score'] ?? 0,
      maîtrisé: map['maîtrisé'] ?? false,
    );
  }

  // Calculer le niveau de progression (0-5 étoiles)
  int get niveau {
    if (maîtrisé) return 5;
    if (score >= 80) return 4;
    if (score >= 60) return 3;
    if (score >= 40) return 2;
    if (score >= 20) return 1;
    return 0;
  }

  // Obtenir la couleur du niveau
  Color get niveauCouleur {
    switch (niveau) {
      case 5:
        return const Color(0xFFFFD700); // Or
      case 4:
        return const Color(0xFF4CAF50); // Vert
      case 3:
        return const Color(0xFF8BC34A); // Vert clair
      case 2:
        return const Color(0xFFFFC107); // Jaune
      case 1:
        return const Color(0xFFFF9800); // Orange
      default:
        return const Color(0xFF9E9E9E); // Gris
    }
  }

  @override
  String toString() {
    return 'Progression(vireLangueId: $vireLangueId, score: $score, niveau: $niveau)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Progression && other.id == id;
  }

  @override
  int get hashCode {
    return id.hashCode;
  }
}
