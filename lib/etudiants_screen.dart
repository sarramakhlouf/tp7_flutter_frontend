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
      } else {
        debugPrint(
          "Erreur lors de la récupération des classes : ${res.statusCode}",
        );
      }
    } catch (e) {
      debugPrint("Exception getClasses: $e");
    }
  }

  // Récupérer les étudiants selon la classe sélectionnée
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
      } else {
        debugPrint(
          "Erreur lors de la récupération des étudiants : ${res.statusCode}",
        );
      }
    } catch (e) {
      debugPrint("Exception getEtudiantsByClasse: $e");
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
            // Dropdown pour choisir la classe
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
            // Liste des étudiants
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
