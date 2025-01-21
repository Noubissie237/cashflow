class Utilisateur {
  int? id;
  String nom;
  String email;
  String motDePasse;

  Utilisateur({
    this.id,
    required this.nom,
    required this.email,
    required this.motDePasse,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nom': nom,
      'email': email,
      'motDePasse': motDePasse,
    };
  }

  factory Utilisateur.fromMap(Map<String, dynamic> map) {
    return Utilisateur(
      id: map['id'],
      nom: map['nom'],
      email: map['email'],
      motDePasse: map['motDePasse'],
    );
  }
}
