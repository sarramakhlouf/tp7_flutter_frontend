import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'matiere.dart';

class MatiereScreen extends StatefulWidget {
  final String token; // token JWT reçu depuis le login
  const MatiereScreen({super.key, required this.token});

  @override
  State<MatiereScreen> createState() => _MatiereScreenState();
}

class _MatiereScreenState extends State<MatiereScreen> {
  late Future<List<Matiere>> futureMatieres;

  Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer ${widget.token}',
  };

  @override
  void initState() {
    super.initState();
    futureMatieres = fetchMatieres();
  }

  Future<List<Matiere>> fetchMatieres() async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8088/api/matieres'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((m) => Matiere.fromJson(m)).toList();
    } else {
      throw Exception('Impossible de charger les matières');
    }
  }

  Future<void> addMatiere(String intMat, String description) async {
    final response = await http.post(
      Uri.parse('http://10.0.2.2:8088/api/matieres/add'),
      headers: headers,
      body: json.encode({'intMat': intMat, 'description': description}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      setState(() {
        futureMatieres = fetchMatieres();
      });
    } else {
      throw Exception('Erreur lors de l\'ajout de la matière');
    }
  }

  Future<void> updateMatiere(int id, String intMat, String description) async {
    final response = await http.put(
      Uri.parse('http://10.0.2.2:8088/api/matieres/edit/$id'),
      headers: headers,
      body: json.encode({'intMat': intMat, 'description': description}),
    );

    if (response.statusCode == 200) {
      setState(() {
        futureMatieres = fetchMatieres();
      });
    } else {
      throw Exception('Erreur lors de la modification');
    }
  }

  Future<void> deleteMatiere(int id) async {
    final response = await http.delete(
      Uri.parse('http://10.0.2.2:8088/api/matieres/$id'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      setState(() {
        futureMatieres = fetchMatieres();
      });
    } else {
      throw Exception('Erreur lors de la suppression');
    }
  }

  void _showMatiereDialog({Matiere? matiere}) {
    final intMatController = TextEditingController(
      text: matiere != null ? matiere.intMat : '',
    );
    final descController = TextEditingController(
      text: matiere != null ? matiere.description : '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          matiere == null ? 'Ajouter une matière' : 'Modifier la matière',
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: intMatController,
              decoration: const InputDecoration(labelText: 'Intitulé'),
            ),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              final intMat = intMatController.text;
              final desc = descController.text;
              if (intMat.isNotEmpty && desc.isNotEmpty) {
                if (matiere == null) {
                  addMatiere(intMat, desc);
                } else {
                  updateMatiere(matiere.codMat!, intMat, desc);
                }
                Navigator.pop(context);
              }
            },
            child: Text(matiere == null ? 'Ajouter' : 'Modifier'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(Matiere matiere) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la matière'),
        content: Text('Voulez-vous vraiment supprimer "${matiere.intMat}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              deleteMatiere(matiere.codMat!);
              Navigator.pop(context);
            },
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
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
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.orange),
                          onPressed: () => _showMatiereDialog(matiere: matiere),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _confirmDelete(matiere),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.purple,
        onPressed: () => _showMatiereDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
