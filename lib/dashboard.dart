import 'package:flutter/material.dart';
import 'package:tp7_flutter_frontend/drawer.dart';

class Dashboard extends StatelessWidget {
  final String token; // <-- doit être final
  const Dashboard({required this.token, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        backgroundColor: Colors.purple,
      ),
      drawer: AppDrawer(token: token),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Connexion réussie !", style: TextStyle(fontSize: 20)),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
