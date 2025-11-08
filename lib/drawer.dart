import 'package:flutter/material.dart';
import 'package:tp7_flutter_frontend/matieres_screen.dart';
import 'etudiants_screen.dart';
import 'formations_screen.dart';
import 'absences_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.purple),
            child: Text(
              'Menu de gestion',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          // ✅ Formations
          ListTile(
            title: const Text('Formations'),
            leading: const Icon(Icons.school_outlined),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FormationScreen(),
                ),
              );
            },
          ),
          // ✅ Étudiants
          ListTile(
            title: const Text('Étudiants'),
            leading: const Icon(Icons.person_outline),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EtudiantScreen()),
              );
            },
          ),
          //Absences
          ListTile(
            title: const Text('Absences'),
            leading: const Icon(Icons.book_outlined),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AbsenceScreen()),
              );
            },
          ),
          //Matieres
          ListTile(
            title: const Text('Matieres'),
            leading: const Icon(Icons.book_outlined),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MatiereScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
