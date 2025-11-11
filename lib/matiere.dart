class Matiere {
  final int? codMat;
  final String intMat;
  final String description;

  Matiere({this.codMat, required this.intMat, required this.description});

  factory Matiere.fromJson(Map<String, dynamic> json) {
    return Matiere(
      codMat: json['codMat'],
      intMat: json['intMat'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'codMat': codMat, 'intMat': intMat, 'description': description};
  }
}
