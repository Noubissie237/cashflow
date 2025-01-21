class Objectif {
  int? id;
  double montantCible;
  String? description;
  DateTime dateLimite;
  double montantEconomise;
  int utilisateurId;
  bool estPrincipal; // Nouveau champ

  Objectif({
    this.id,
    required this.montantCible,
    this.description,
    required this.dateLimite,
    this.montantEconomise = 0,
    required this.utilisateurId,
    required this.estPrincipal, // Nouveau champ
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'description': description,
      'montantCible': montantCible,
      'dateLimite': dateLimite.toIso8601String(),
      'montantEconomise': montantEconomise,
      'utilisateurId': utilisateurId,
      'estPrincipal': estPrincipal ? 1 : 0, // Convertir bool en int
    };
  }

  factory Objectif.fromMap(Map<String, dynamic> map) {
    return Objectif(
      id: map['id'],
      description: map['description'],
      montantCible: map['montantCible'],
      dateLimite: DateTime.parse(map['dateLimite']),
      montantEconomise: map['montantEconomise'],
      utilisateurId: map['utilisateurId'],
      estPrincipal: map['estPrincipal'] == 1, // Convertir int en bool
    );
  }
}