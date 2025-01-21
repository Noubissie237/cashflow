class Caisse {
  int? id;
  String? description;
  double montant;
  DateTime date;
  int utilisateurId;

  Caisse({
    this.id,
    this.description,
    required this.montant,
    required this.date,
    required this.utilisateurId,
  });

  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'description': description,
      'montant': montant,
      'date': date.toIso8601String(),
      'utilisateurId': utilisateurId,
    };
  }

  
  factory Caisse.fromMap(Map<String, dynamic> map) {
    return Caisse(
      id: map['id'],
      description: map['description'],
      montant: map['montant'],
      date: DateTime.parse(map['date']),
      utilisateurId: map['utilisateurId'],
    );
  }
}