import 'package:hive/hive.dart';

part 'vire_langue.g.dart';

@HiveType(typeId: 0)
class VireLangue {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String texte;
  
  @HiveField(2)
  final int difficulte; // 1 = Facile, 2 = Moyen, 3 = Difficile
  
  @HiveField(3)
  final String categorie;
  
  @HiveField(4)
  final String? description;
  
  @HiveField(5)
  final DateTime dateCreation;

  VireLangue({
    required this.id,
    required this.texte,
    required this.difficulte,
    required this.categorie,
    this.description,
    DateTime? dateCreation,
  }) : dateCreation = dateCreation ?? DateTime.now();

  // Niveaux de difficulte
  static const int facile = 1;
  static const int moyen = 2;
  static const int difficile = 3;

  // Categories par defaut
  static const List<String> categories = [
    'Classiques',
    'Drôles',
    'Animaux',
    'Nourriture',
    'Voyage',
    'Personnages',
  ];

  String get difficulteLibelle {
    switch (difficulte) {
      case 1:
        return 'Facile';
      case 2:
        return 'Moyen';
      case 3:
        return 'Difficile';
      default:
        return 'Inconnu';
    }
  }

  Color get difficulteCouleur {
    switch (difficulte) {
      case 1:
        return const Color(0xFF4CAF50); // Vert
      case 2:
        return const Color(0xFFFFC107); // Jaune
      case 3:
        return const Color(0xFFF44336); // Rouge
      default:
        return const Color(0xFF9E9E9E); // Gris
    }
  }

  VireLangue copyWith({
    String? id,
    String? texte,
    int? difficulte,
    String? categorie,
    String? description,
    DateTime? dateCreation,
  }) {
    return VireLangue(
      id: id ?? this.id,
      texte: texte ?? this.texte,
      difficulte: difficulte ?? this.difficulte,
      categorie: categorie ?? this.categorie,
      description: description ?? this.description,
      dateCreation: dateCreation ?? this.dateCreation,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'texte': texte,
      'difficulte': difficulte,
      'categorie': categorie,
      'description': description,
      'dateCreation': dateCreation.toIso8601String(),
    };
  }

  factory VireLangue.fromMap(Map<String, dynamic> map) {
    return VireLangue(
      id: map['id'] ?? '',
      texte: map['texte'] ?? '',
      difficulte: map['difficulte'] ?? 1,
      categorie: map['categorie'] ?? 'Classiques',
      description: map['description'],
      dateCreation: DateTime.tryParse(map['dateCreation'] ?? ''),
    );
  }

  @override
  String toString() {
    return 'VireLangue(id: $id, texte: $texte, difficulte: $difficulte)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VireLangue && other.id == id;
  }

  @override
  int get hashCode {
    return id.hashCode;
  }
}
