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
  final DateTime dernierePratique;
  
  @HiveField(4)
  final DateTime? prochainePratique;
  
  @HiveField(5)
  final int score; // 0-100
  
  @HiveField(6)
  final bool maitrise;

  Progression({
    required this.id,
    required this.vireLangueId,
    this.nombreRepetitions = 0,
    DateTime? dernierePratique,
    this.prochainePratique,
    this.score = 0,
    this.maitrise = false,
  }) : dernierePratique = dernierePratique ?? DateTime.now();

  Progression copyWith({
    String? id,
    String? vireLangueId,
    int? nombreRepetitions,
    DateTime? dernierePratique,
    DateTime? prochainePratique,
    int? score,
    bool? maitrise,
  }) {
    return Progression(
      id: id ?? this.id,
      vireLangueId: vireLangueId ?? this.vireLangueId,
      nombreRepetitions: nombreRepetitions ?? this.nombreRepetitions,
      dernierePratique: dernierePratique ?? this.dernierePratique,
      prochainePratique: prochainePratique ?? this.prochainePratique,
      score: score ?? this.score,
      maitrise: maitrise ?? this.maitrise,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vireLangueId': vireLangueId,
      'nombreRepetitions': nombreRepetitions,
      'dernierePratique': dernierePratique.toIso8601String(),
      'prochainePratique': prochainePratique?.toIso8601String(),
      'score': score,
      'maitrise': maitrise,
    };
  }

  factory Progression.fromMap(Map<String, dynamic> map) {
    return Progression(
      id: map['id'] ?? '',
      vireLangueId: map['vireLangueId'] ?? '',
      nombreRepetitions: map['nombreRepetitions'] ?? 0,
      dernierePratique: DateTime.tryParse(map['dernierePratique'] ?? '') ?? DateTime.now(),
      prochainePratique: DateTime.tryParse(map['prochainePratique'] ?? ''),
      score: map['score'] ?? 0,
      maitrise: map['maitrise'] ?? false,
    );
  }

  // Calculer le niveau de progression (0-5 etoiles)
  int get niveau {
    if (maitrise) return 5;
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
