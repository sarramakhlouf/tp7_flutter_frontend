import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'absence.dart';

class AbsenceScreen extends StatefulWidget {
  final String token; // token JWT reçu depuis le login
  const AbsenceScreen({super.key, required this.token});

  @override
  State<AbsenceScreen> createState() => _AbsenceScreenState();
}

class _AbsenceScreenState extends State<AbsenceScreen> {
  final String baseUrl = "http://10.0.2.2:8088";

  List<Absence> absences = [];
  bool isLoading = true;

  List etudiants = [];
  List matieres = [];

  Map<String, dynamic>? selectedEtudiant;
  Map<String, dynamic>? selectedMatiere;
  String? classeAssociee;

  final _dateController = TextEditingController();
  final _nhaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAbsences();
    _fetchEtudiants();
    _fetchMatieres();
  }

  // --------------------- Requêtes sécurisées ---------------------
  Future<void> _loadAbsences() async {
    try {
      final res = await http.get(
        Uri.parse("$baseUrl/api/absences"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (res.statusCode == 200) {
        final data = json.decode(res.body) as List;
        setState(() {
          absences = data.map((e) => Absence.fromJson(e)).toList();
          isLoading = false;
        });
      } else {
        _showSnack("Erreur chargement absences : ${res.statusCode}");
      }
    } catch (e) {
      _showSnack("Erreur chargement absences : $e");
    }
  }

  Future<void> _fetchEtudiants() async {
    try {
      final res = await http.get(
        Uri.parse("$baseUrl/api/etudiants"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        setState(() {
          etudiants = data;
        });
      } else {
        _showSnack("Erreur chargement étudiants : ${res.statusCode}");
      }
    } catch (e) {
      _showSnack("Erreur chargement étudiants : $e");
    }
  }

  Future<void> _fetchMatieres() async {
    try {
      final res = await http.get(
        Uri.parse("$baseUrl/api/matieres"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        setState(() {
          matieres = data;
        });
      } else {
        _showSnack("Erreur chargement matières : ${res.statusCode}");
      }
    } catch (e) {
      _showSnack("Erreur chargement matières : $e");
    }
  }

  void _onSelectEtudiant(Map<String, dynamic> e) {
    setState(() {
      selectedEtudiant = e;
      classeAssociee = e["classe"]?["nomClass"] ?? "Classe inconnue";
    });
  }

  Future<void> _insertAbsence() async {
    if (selectedEtudiant == null || selectedMatiere == null) {
      _showSnack("Veuillez sélectionner un étudiant et une matière.");
      return;
    }

    final nce = selectedEtudiant!["id"];
    final codMat = selectedMatiere!["codMat"];

    if (nce == null || codMat == null) {
      _showSnack("Les identifiants (id/codMat) sont invalides.");
      return;
    }

    try {
      final abs = {
        "nce": nce,
        "codMat": codMat,
        "dateA": _dateController.text,
        "nha": int.parse(_nhaController.text),
      };

      final res = await http.post(
        Uri.parse("$baseUrl/api/absences"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
        body: json.encode(abs),
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        _clearFields();
        _loadAbsences();
        _showSnack("Absence ajoutée avec succès");
      } else {
        _showSnack("Erreur ajout absence : ${res.statusCode}");
      }
    } catch (e) {
      _showSnack("Erreur ajout absence : $e");
    }
  }

  Future<void> _deleteAbsence(Absence a) async {
    try {
      final res = await http.delete(
        Uri.parse("$baseUrl/api/absences/delete"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (res.statusCode == 200) {
        _loadAbsences();
        _showSnack("Absence supprimée");
      } else {
        _showSnack("Erreur suppression : ${res.statusCode}");
      }
    } catch (e) {
      _showSnack("Erreur suppression : $e");
    }
  }

  void _clearFields() {
    setState(() {
      selectedEtudiant = null;
      selectedMatiere = null;
      classeAssociee = null;
    });
    _dateController.clear();
    _nhaController.clear();
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // --------------------- UI ---------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des absences'),
        backgroundColor: Colors.purple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            DropdownButtonFormField<Map<String, dynamic>>(
              decoration: const InputDecoration(
                labelText: "Sélectionner un étudiant",
                border: OutlineInputBorder(),
              ),
              value: selectedEtudiant,
              items: etudiants.map<DropdownMenuItem<Map<String, dynamic>>>((e) {
                return DropdownMenuItem(
                  value: e,
                  child: Text("${e['prenom']} ${e['nom']}"),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) _onSelectEtudiant(value);
              },
            ),
            const SizedBox(height: 10),
            TextFormField(
              readOnly: true,
              decoration: InputDecoration(
                labelText: "Classe associée",
                border: const OutlineInputBorder(),
                hintText: classeAssociee ?? "Aucune classe sélectionnée",
              ),
              controller: TextEditingController(text: classeAssociee ?? ""),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<Map<String, dynamic>>(
              decoration: const InputDecoration(
                labelText: "Sélectionner une matière",
                border: OutlineInputBorder(),
              ),
              value: selectedMatiere,
              items: matieres.map<DropdownMenuItem<Map<String, dynamic>>>((m) {
                return DropdownMenuItem(
                  value: m,
                  child: Text("${m['intMat']} (${m['codMat']})"),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedMatiere = value;
                });
              },
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _dateController,
              decoration: const InputDecoration(
                labelText: 'Date absence (AAAA-MM-JJ)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _nhaController,
              decoration: const InputDecoration(
                labelText: 'Nombre d’heures (NHA)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _insertAbsence,
                  icon: const Icon(Icons.add),
                  label: const Text('Insérer'),
                ),
                ElevatedButton.icon(
                  onPressed: _clearFields,
                  icon: const Icon(Icons.clear),
                  label: const Text('Annuler'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(),
            const Text(
              'Liste des absences',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : absences.isEmpty
                  ? const Center(child: Text('Aucune absence enregistrée'))
                  : ListView.builder(
                      itemCount: absences.length,
                      itemBuilder: (context, index) {
                        final a = absences[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          child: ListTile(
                            title: Text(
                              'Matière: ${a.codMat} | Étudiant: ${a.nce}',
                            ),
                            subtitle: Text(
                              'Date: ${a.dateA} | NHA: ${a.nha} h',
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => _deleteAbsence(a),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
