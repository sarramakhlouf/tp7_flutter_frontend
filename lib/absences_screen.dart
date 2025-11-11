import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'absence_service.dart';
import 'absence.dart';

class AbsenceScreen extends StatefulWidget {
  const AbsenceScreen({super.key});

  @override
  State<AbsenceScreen> createState() => _AbsenceScreenState();
}

class _AbsenceScreenState extends State<AbsenceScreen> {
  final AbsenceService service = AbsenceService();

  List<Absence> absences = [];
  bool isLoading = true;

  // Données pour les listes déroulantes
  List etudiants = [];
  List matieres = [];

  Map<String, dynamic>? selectedEtudiant;
  Map<String, dynamic>? selectedMatiere;

  final String baseUrl = "http://10.0.2.2:8088";

  // Champs
  final _dateController = TextEditingController();
  final _nhaController = TextEditingController();
  String? classeAssociee;

  @override
  void initState() {
    super.initState();
    _loadAbsences();
    _fetchEtudiants();
    _fetchMatieres();
  }

  Future<void> _loadAbsences() async {
    try {
      final list = await service.getAll();
      setState(() {
        absences = list;
        isLoading = false;
      });
    } catch (e) {
      _showSnack("Erreur de chargement : $e");
    }
  }

  Future<void> _fetchEtudiants() async {
    try {
      final res = await http.get(Uri.parse("$baseUrl/api/etudiants"));
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        setState(() {
          etudiants = data;
        });
      }
    } catch (e) {
      _showSnack("Erreur chargement étudiants : $e");
    }
  }

  Future<void> _fetchMatieres() async {
    try {
      final res = await http.get(Uri.parse("$baseUrl/api/matieres"));
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        setState(() {
          matieres = data;
        });
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
    try {
      if (selectedEtudiant == null || selectedMatiere == null) {
        _showSnack("Veuillez sélectionner un étudiant et une matière.");
        return;
      }

      final nce = selectedEtudiant!["id"]; // ✅ correspond à l'ID réel
      final codMat = selectedMatiere!["codMat"];

      if (nce == null || codMat == null) {
        _showSnack("Les identifiants (id/codMat) sont invalides.");
        return;
      }

      final abs = Absence(
        codMat: codMat is int ? codMat : int.parse(codMat.toString()),
        nce: nce is int ? nce : int.parse(nce.toString()),
        dateA: _dateController.text,
        nha: int.parse(_nhaController.text),
      );

      await service.insert(abs);
      _clearFields();
      _loadAbsences();
      _showSnack("Absence ajoutée avec succès");
    } catch (e) {
      _showSnack("Erreur d’ajout : $e");
    }
  }

  Future<void> _deleteAbsence(Absence abs) async {
    try {
      await service.delete(abs);
      _loadAbsences();
      _showSnack("Absence supprimée");
    } catch (e) {
      _showSnack("Erreur de suppression : $e");
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
            // ---- Liste déroulante des étudiants ----
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

            // ---- Classe associée ----
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

            // ---- Liste déroulante des matières ----
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

            // ---- Date et nombre d’heures ----
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

            // ---- Boutons ----
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

            // ---- Liste des absences ----
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
