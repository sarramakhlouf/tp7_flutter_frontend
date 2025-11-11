import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EtudiantScreen extends StatefulWidget {
  const EtudiantScreen({super.key});

  @override
  State<EtudiantScreen> createState() => _EtudiantScreenState();
}

class _EtudiantScreenState extends State<EtudiantScreen> {
  List classes = [];
  List etudiants = [];
  int? selectedClasse;

  final TextEditingController newClasseController = TextEditingController();

  final String baseUrl = "http://10.0.2.2:8088";

  @override
  void initState() {
    super.initState();
    getClasses();
  }

  Future<void> getClasses() async {
    try {
      final res = await http.get(Uri.parse("$baseUrl/api/classes"));
      if (res.statusCode == 200) {
        setState(() {
          classes = json.decode(res.body);
        });
      }
    } catch (e) {
      debugPrint("Exception getClasses: $e");
    }
  }

  Future<void> getEtudiantsByClasse() async {
    if (selectedClasse == null) return;
    try {
      final res = await http.get(
        Uri.parse("$baseUrl/api/etudiants/classe/$selectedClasse"),
      );
      if (res.statusCode == 200) {
        setState(() {
          etudiants = json.decode(res.body);
        });
      }
    } catch (e) {
      debugPrint("Exception getEtudiantsByClasse: $e");
    }
  }

  Future<void> addClasse() async {
    if (newClasseController.text.isEmpty) return;
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/api/classes/add"),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"nomClass": newClasseController.text}),
      );
      if (res.statusCode == 200 || res.statusCode == 201) {
        newClasseController.clear();
        await getClasses();
      }
    } catch (e) {
      debugPrint("Exception addClasse: $e");
    }
  }

  Future<void> addOrUpdateEtudiant({
    int? id,
    required String prenom,
    required String nom,
    required String dateNais,
    required String lieuNais,
  }) async {
    if (selectedClasse == null) return;
    final url = id == null
        ? "$baseUrl/api/etudiants/add"
        : "$baseUrl/api/etudiants/$id";

    final method = id == null ? "POST" : "PUT";

    try {
      final res = await (method == "POST"
          ? http.post(
              Uri.parse(url),
              headers: {"Content-Type": "application/json"},
              body: json.encode({
                "prenom": prenom,
                "nom": nom,
                "dateNais": dateNais,
                "lieuNais": lieuNais,
                "classe": {"id": selectedClasse},
              }),
            )
          : http.put(
              Uri.parse(url),
              headers: {"Content-Type": "application/json"},
              body: json.encode({
                "prenom": prenom,
                "nom": nom,
                "dateNais": dateNais,
                "lieuNais": lieuNais,
                "classe": {"id": selectedClasse},
              }),
            ));

      if (res.statusCode == 200 || res.statusCode == 201) {
        getEtudiantsByClasse();
      }
    } catch (e) {
      debugPrint("Exception addOrUpdateEtudiant: $e");
    }
  }

  void showEtudiantDialog({Map? etudiant}) {
    final prenomController = TextEditingController(text: etudiant?["prenom"]);
    final nomController = TextEditingController(text: etudiant?["nom"]);
    final dateController = TextEditingController(text: etudiant?["dateNais"]);
    final lieuController = TextEditingController(text: etudiant?["lieuNais"]);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          etudiant == null ? "Ajouter un étudiant" : "Modifier étudiant",
        ),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: prenomController,
                decoration: const InputDecoration(labelText: "Prénom"),
              ),
              TextField(
                controller: nomController,
                decoration: const InputDecoration(labelText: "Nom"),
              ),
              TextField(
                controller: dateController,
                decoration: const InputDecoration(
                  labelText: "Date de naissance (YYYY-MM-DD)",
                ),
              ),
              TextField(
                controller: lieuController,
                decoration: const InputDecoration(
                  labelText: "Lieu de naissance",
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () {
              addOrUpdateEtudiant(
                id: etudiant?["id"],
                prenom: prenomController.text,
                nom: nomController.text,
                dateNais: dateController.text,
                lieuNais: lieuController.text,
              );
              Navigator.pop(context);
            },
            child: Text(etudiant == null ? "Ajouter" : "Modifier"),
          ),
        ],
      ),
    );
  }

  void deleteEtudiant(int id) async {
    try {
      final res = await http.delete(Uri.parse("$baseUrl/api/etudiants/$id"));
      if (res.statusCode == 200) {
        getEtudiantsByClasse();
      }
    } catch (e) {
      debugPrint("Exception deleteEtudiant: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Étudiants")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: newClasseController,
                    decoration: const InputDecoration(
                      labelText: "Nouvelle classe",
                    ),
                  ),
                ),
                IconButton(icon: const Icon(Icons.add), onPressed: addClasse),
              ],
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<int>(
              hint: const Text("Choisir une classe"),
              value: selectedClasse,
              items: classes.map<DropdownMenuItem<int>>((c) {
                return DropdownMenuItem<int>(
                  value: c["id"],
                  child: Text(c["nomClass"] ?? "Classe inconnue"),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedClasse = value;
                  getEtudiantsByClasse();
                });
              },
            ),
            const SizedBox(height: 20),
            if (selectedClasse != null)
              ElevatedButton(
                onPressed: () => showEtudiantDialog(),
                child: const Text("Ajouter un étudiant"),
              ),
            const SizedBox(height: 20),
            Expanded(
              child: etudiants.isEmpty
                  ? const Center(child: Text("Aucun étudiant à afficher"))
                  : ListView.builder(
                      itemCount: etudiants.length,
                      itemBuilder: (context, index) {
                        final e = etudiants[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            leading: const Icon(Icons.person),
                            title: Text(
                              "${e["prenom"] ?? ""} ${e["nom"] ?? ""}",
                            ),
                            subtitle: Text(
                              "Né le: ${e["dateNais"] ?? "inconnu"} - Lieu: ${e["lieuNais"] ?? "inconnu"}",
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.blue,
                                  ),
                                  onPressed: () =>
                                      showEtudiantDialog(etudiant: e),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    if (e["id"] != null)
                                      deleteEtudiant(e["id"]);
                                  },
                                ),
                              ],
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
