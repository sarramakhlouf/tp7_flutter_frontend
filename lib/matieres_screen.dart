import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tp7_flutter_frontend/matiere.dart';
import 'dart:convert';

class MatiereScreen extends StatefulWidget {
  const MatiereScreen({super.key});

  @override
  State<MatiereScreen> createState() => _MatiereScreenState();
}

class _MatiereScreenState extends State<MatiereScreen> {
  late Future<List<Matiere>> futureMatieres;

  @override
  void initState() {
    super.initState();
    futureMatieres = fetchMatieres();
  }

  Future<List<Matiere>> fetchMatieres() async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8088/api/matieres'),
    );

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((m) => Matiere.fromJson(m)).toList();
    } else {
      throw Exception('Impossible de charger les matières');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liste des matières'),
        backgroundColor: Colors.purple,
      ),
      body: FutureBuilder<List<Matiere>>(
        future: futureMatieres,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Aucune matière trouvée'));
          } else {
            final matieres = snapshot.data!;
            return ListView.builder(
              itemCount: matieres.length,
              itemBuilder: (context, index) {
                final matiere = matieres[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  child: ListTile(
                    leading: const Icon(
                      Icons.book_outlined,
                      color: Colors.purple,
                    ),
                    title: Text(matiere.intMat),
                    subtitle: Text(matiere.description),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
