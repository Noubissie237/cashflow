class Objectif {
  int? id;
  double montantCible;
  DateTime dateLimite;
  double montantEconomise;
  int utilisateurId;

  Objectif({
    this.id,
    required this.montantCible,
    required this.dateLimite,
    this.montantEconomise = 0,
    required this.utilisateurId,
  });

  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'montantCible': montantCible,
      'dateLimite': dateLimite.toIso8601String(),
      'montantEconomise': montantEconomise,
      'utilisateurId': utilisateurId,
    };
  }

  
  factory Objectif.fromMap(Map<String, dynamic> map) {
    return Objectif(
      id: map['id'],
      montantCible: map['montantCible'],
      dateLimite: DateTime.parse(map['dateLimite']),
      montantEconomise: map['montantEconomise'],
      utilisateurId: map['utilisateurId'],
    );
  }
}