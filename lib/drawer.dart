import 'package:flutter/material.dart';
import 'etudiants_screen.dart';
import 'formations_screen.dart';

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
          ListTile(
            title: const Text('Formations'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FormationScreen(),
                ),
              );
            },
          ),
          ListTile(
            title: const Text('Étudiants'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EtudiantScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
