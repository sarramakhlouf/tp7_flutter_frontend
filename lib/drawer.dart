import 'package:flutter/material.dart';
import 'package:tp7_flutter_frontend/matieres_screen.dart';
import 'package:tp7_flutter_frontend/user.dart';
import 'etudiants_screen.dart';
import 'formations_screen.dart';
import 'absences_screen.dart';
import 'login.dart';

class AppDrawer extends StatelessWidget {
  final String token; // token passé depuis le Dashboard ou le Login
  const AppDrawer({super.key, required this.token});

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
          // Formations
          ListTile(
            title: const Text('Formations'),
            leading: const Icon(Icons.school_outlined),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FormationScreen(token: token),
                ),
              );
            },
          ),
          // Étudiants
          ListTile(
            title: const Text('Étudiants'),
            leading: const Icon(Icons.person_outline),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EtudiantScreen(token: token),
                ),
              );
            },
          ),
          // Absences
          ListTile(
            title: const Text('Absences'),
            leading: const Icon(Icons.book_outlined),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AbsenceScreen(token: token),
                ),
              );
            },
          ),
          // Matières
          ListTile(
            title: const Text('Matieres'),
            leading: const Icon(Icons.menu_book), // nouvelle icône
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MatiereScreen(token: token),
                ),
              );
            },
          ),
          const Divider(),
          // Logout
          ListTile(
            title: const Text('Déconnexion'),
            leading: const Icon(Icons.logout, color: Colors.red),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const Login()),
              );
            },
          ),
        ],
      ),
    );
  }
}
