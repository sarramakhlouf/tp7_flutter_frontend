class Absence {
  final int codMat;
  final int nce;
  final String dateA;
  final int nha;

  Absence({
    required this.codMat,
    required this.nce,
    required this.dateA,
    required this.nha,
  });

  // Sérialisation pour envoyer au backend
  Map<String, dynamic> toJson() {
    return {"codMat": codMat, "nce": nce, "dateA": dateA, "nha": nha};
  }

  // Désérialisation depuis le backend
  factory Absence.fromJson(Map<String, dynamic> json) {
    return Absence(
      codMat: json["codMat"],
      nce: json["nce"],
      dateA: json["dateA"],
      nha: json["nha"],
    );
  }
}
