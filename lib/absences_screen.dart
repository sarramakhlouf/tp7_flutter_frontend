import 'package:flutter/material.dart';
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

  // Champs du formulaire
  final _codMatController = TextEditingController();
  final _nceController = TextEditingController();
  final _dateController = TextEditingController();
  final _nhaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAbsences();
  }

  Future<void> _loadAbsences() async {
    try {
      final list = await service.getAll();
      setState(() {
        absences = list;
        isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur de chargement : $e')));
    }
  }

  Future<void> _insertAbsence() async {
    try {
      final abs = Absence(
        codMat: int.parse(_codMatController.text),
        nce: int.parse(_nceController.text),
        dateA: _dateController.text,
        nha: int.parse(_nhaController.text),
      );
      await service.insert(abs);
      _clearFields();
      _loadAbsences();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Absence ajoutée avec succès')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur d’ajout : $e')));
    }
  }

  Future<void> _deleteAbsence(Absence abs) async {
    try {
      await service.delete(abs);
      _loadAbsences();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Absence supprimée')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur de suppression : $e')));
    }
  }

  void _clearFields() {
    _codMatController.clear();
    _nceController.clear();
    _dateController.clear();
    _nhaController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des absences'),
        backgroundColor: Colors.purple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // --- FORMULAIRE D’AJOUT ---
            TextField(
              controller: _codMatController,
              decoration: const InputDecoration(
                labelText: 'Code matière',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nceController,
              decoration: const InputDecoration(
                labelText: 'NCE étudiant',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _dateController,
              decoration: const InputDecoration(
                labelText: 'Date absence (AAAA-MM-JJ)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nhaController,
              decoration: const InputDecoration(
                labelText: 'Nombre d’heures (NHA)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),

            // --- BOUTONS ---
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

            // --- LISTE ---
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
