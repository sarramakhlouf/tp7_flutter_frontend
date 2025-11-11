import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class FormationScreen extends StatefulWidget {
  final String token; // token JWT reçu depuis le login
  const FormationScreen({super.key, required this.token});

  @override
  State<FormationScreen> createState() => _FormationScreenState();
}

class _FormationScreenState extends State<FormationScreen> {
  List formations = [];
  final TextEditingController _titreController = TextEditingController();
  final String apiUrl = "http://10.0.2.2:8088/formations";

  Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer ${widget.token}',
  };

  @override
  void initState() {
    super.initState();
    getFormations();
  }

  Future<void> getFormations() async {
    try {
      final res = await http.get(Uri.parse(apiUrl), headers: headers);
      if (res.statusCode == 200) {
        setState(() {
          formations = json.decode(res.body);
        });
      } else {
        debugPrint("Erreur getFormations: ${res.statusCode}");
      }
    } catch (e) {
      debugPrint("Exception getFormations: $e");
    }
  }

  Future<void> addFormation() async {
    if (_titreController.text.isEmpty) return;
    try {
      final res = await http.post(
        Uri.parse('$apiUrl/add'),
        headers: headers,
        body: json.encode({'titre': _titreController.text}),
      );
      if (res.statusCode == 200 || res.statusCode == 201) {
        _titreController.clear();
        getFormations();
      } else {
        debugPrint("Erreur addFormation: ${res.statusCode}");
      }
    } catch (e) {
      debugPrint("Exception addFormation: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Formations")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _titreController,
                    decoration: const InputDecoration(
                      labelText: "Nouvelle formation",
                    ),
                  ),
                ),
                IconButton(
                  onPressed: addFormation,
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: formations.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(formations[index]["titre"] ?? "Titre inconnu"),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
