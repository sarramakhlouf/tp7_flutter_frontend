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

  Future<void> getClasses() async {
    final res = await http.get(Uri.parse("$baseUrl/classes"));
    setState(() {
      classes = json.decode(res.body);
    });
  }

  Future<void> getEtudiantsByClasse() async {
    if (selectedClasse == null) return;
    final res = await http.get(
      Uri.parse("$baseUrl/etudiants/classe/$selectedClasse"),
    );
    setState(() {
      etudiants = json.decode(res.body);
    });
  }

  @override
  void initState() {
    super.initState();
    getClasses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Étudiants")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField(
              hint: const Text("Choisir une classe"),
              items: classes.map<DropdownMenuItem<int>>((c) {
                return DropdownMenuItem<int>(
                  value: c["id"],
                  child: Text(c["nom"]),
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
            Expanded(
              child: ListView.builder(
                itemCount: etudiants.length,
                itemBuilder: (context, index) {
                  final e = etudiants[index];
                  return ListTile(
                    leading: const Icon(Icons.person),
                    title: Text("${e["prenom"]} ${e["nom"]}"),
                    subtitle: Text(e["email"]),
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
