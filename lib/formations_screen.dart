import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class FormationScreen extends StatefulWidget {
  const FormationScreen({super.key});

  @override
  State<FormationScreen> createState() => _FormationScreenState();
}

class _FormationScreenState extends State<FormationScreen> {
  List formations = [];
  final TextEditingController _titreController = TextEditingController();
  final String apiUrl = "http://10.0.2.2:8088/formations";

  Future<void> getFormations() async {
    final res = await http.get(Uri.parse(apiUrl));
    setState(() {
      formations = json.decode(res.body);
    });
  }

  Future<void> addFormation() async {
    if (_titreController.text.isEmpty) return;
    await http.post(
      Uri.parse('$apiUrl/add'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'titre': _titreController.text}),
    );
    _titreController.clear();
    getFormations();
  }

  @override
  void initState() {
    super.initState();
    getFormations();
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
                return ListTile(title: Text(formations[index]["titre"]));
              },
            ),
          ),
        ],
      ),
    );
  }
}
