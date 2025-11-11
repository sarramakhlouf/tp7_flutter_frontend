import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dashboard.dart';
import 'register.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final String url = "http://10.0.2.2:8088/login";

  Future<String> login(String email, String password) async {
    var res = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );

    if (res.statusCode == 200 && res.body.isNotEmpty) {
      if (res.body == "Invalid credentials") {
        throw Exception('Email ou mot de passe incorrect !');
      }
      return res.body;
    } else {
      throw Exception('Erreur lors de la connexion');
    }
  }

  handleLogin() async {
    if (_formKey.currentState!.validate()) {
      try {
        String token = await login(
          _emailController.text,
          _passwordController.text,
        );

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', token);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Dashboard(token: token)),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> checkAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    String? savedToken = prefs.getString('jwt_token');
    if (savedToken != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Dashboard(token: savedToken)),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    checkAutoLogin();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Text(
                    "Login",
                    style: GoogleFonts.poppins(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: "Email"),
                    validator: (val) =>
                        val == null || val.isEmpty ? "Email obligatoire" : null,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(labelText: "Password"),
                    obscureText: true,
                    validator: (val) => val == null || val.isEmpty
                        ? "Mot de passe obligatoire"
                        : null,
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: handleLogin,
                    child: const Text("Se connecter"),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Register(),
                        ),
                      );
                    },
                    child: const Text("Créer un compte"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
