import 'package:flutter/material.dart';
import 'package:n1/auth_provider.dart';
import 'package:n1/splash_screen.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(create: (_) => AuthProvider(), child: const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo app',
      theme: ThemeData(primarySwatch: Colors.grey),
      home: const SplashScreen(),
    );
  }
}
