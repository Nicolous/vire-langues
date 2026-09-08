import 'package:hive/hive.dart';

part 'serie.g.dart';

@HiveType(typeId: 1)
class Serie {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String nom;
  
  @HiveField(2)
  final String description;
  
  @HiveField(3)
  final List<String> vireLangueIds;
  
  @HiveField(4)
  final DateTime dateCreation;
  
  @HiveField(5)
  final DateTime? dateModification;
  
  @HiveField(6)
  final bool estPersonnalisee;

  Serie({
    required this.id,
    required this.nom,
    required this.description,
    required this.vireLangueIds,
    DateTime? dateCreation,
    this.dateModification,
    this.estPersonnalisee = false,
  }) : dateCreation = dateCreation ?? DateTime.now();

  int get nombreVireLangues => vireLangueIds.length;

  Serie copyWith({
    String? id,
    String? nom,
    String? description,
    List<String>? vireLangueIds,
    DateTime? dateCreation,
    DateTime? dateModification,
    bool? estPersonnalisee,
  }) {
    return Serie(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      description: description ?? this.description,
      vireLangueIds: vireLangueIds ?? this.vireLangueIds,
      dateCreation: dateCreation ?? this.dateCreation,
      dateModification: dateModification ?? this.dateModification,
      estPersonnalisee: estPersonnalisee ?? this.estPersonnalisee,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nom': nom,
      'description': description,
      'vireLangueIds': vireLangueIds,
      'dateCreation': dateCreation.toIso8601String(),
      'dateModification': dateModification?.toIso8601String(),
      'estPersonnalisee': estPersonnalisee,
    };
  }

  factory Serie.fromMap(Map<String, dynamic> map) {
    return Serie(
      id: map['id'] ?? '',
      nom: map['nom'] ?? '',
      description: map['description'] ?? '',
      vireLangueIds: List<String>.from(map['vireLangueIds'] ?? []),
      dateCreation: DateTime.tryParse(map['dateCreation'] ?? ''),
      dateModification: DateTime.tryParse(map['dateModification'] ?? ''),
      estPersonnalisee: map['estPersonnalisee'] ?? false,
    );
  }

  @override
  String toString() {
    return 'Serie(id: $id, nom: $nom, nombreVireLangues: $nombreVireLangues)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Serie && other.id == id;
  }

  @override
  int get hashCode {
    return id.hashCode;
  }
}
