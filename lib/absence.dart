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

  Map<String, dynamic> toJson() => {
    'codMat': codMat,
    'nce': nce,
    'dateA': dateA,
    'nha': nha,
  };
}
