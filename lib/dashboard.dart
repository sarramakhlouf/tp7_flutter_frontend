import 'package:flutter/material.dart';
import 'package:tp7_flutter_frontend/drawer.dart';
import 'package:tp7_flutter_frontend/user.dart';

class Dashboard extends StatelessWidget {
  final User user;
  const Dashboard({required this.user, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Bienvenue ${user.email}"),
        backgroundColor: Colors.purple,
      ),
      drawer: const AppDrawer(),
      body: const Center(
        child: Text("Connexion réussie !", style: TextStyle(fontSize: 20)),
      ),
    );
  }
}
