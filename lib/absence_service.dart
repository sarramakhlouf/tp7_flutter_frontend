import 'dart:convert';
import 'package:http/http.dart' as http;
import 'absence.dart';

class AbsenceService {
  final baseUrl = "http://10.0.2.2:8088/api/absences";

  Future<List<Absence>> getAll() async {
    final res = await http.get(Uri.parse(baseUrl));
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as List;
      return data
          .map(
            (e) => Absence(
              codMat: e['codMat'],
              nce: e['nce'],
              dateA: e['dateA'],
              nha: e['nha'],
            ),
          )
          .toList();
    } else {
      throw Exception('Erreur de chargement');
    }
  }

  Future<void> insert(Absence abs) async {
    await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(abs.toJson()),
    );
  }

  Future<void> delete(Absence abs) async {
    await http.delete(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(abs.toJson()),
    );
  }
}
