import 'package:flutter/material.dart';
import 'package:n1/auth_provider.dart';
import 'package:provider/provider.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: Center(child: Text('Olá, ${auth.authenticatedUser}!')),
    );
  }
}
