import 'package:flutter/material.dart';
import 'package:n1/auth_provider.dart';
import 'package:n1/home.dart';
import 'package:n1/storage.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isLogin = true;
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  void handleSubmit() {
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      showMessage('Preencha todos os campos');
      return;
    }

    if (isLogin) {
      if (Storage.checkLogin(username, password)) {
        context.read<AuthProvider>().login(username);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Home()),
        );
      } else {
        showMessage('Usuário ou senha incorretos');
      }
    } else {
      Storage.userExists(username)
          ? showMessage('Usuário já existe')
          : createUser(username, password);
    }
  }

  void createUser(String username, String password) {
    Storage.addUser(username, password);
    showMessage('Usuário cadastrado!');
    setState(() {
      isLogin = true;
      usernameController.clear();
      passwordController.clear();
    });
  }

  void showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline, size: 80, color: Colors.blue),
              const SizedBox(height: 40),
              Text(
                isLogin ? 'Bem-vindo!' : 'Criar Conta',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),
              TextField(
                controller: usernameController,
                decoration: InputDecoration(
                  labelText: 'Usuário',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Senha',
                  prefixIcon: const Icon(Icons.lock),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton(
                  onPressed: handleSubmit,
                  child: Text(isLogin ? 'Entrar' : 'Cadastrar'),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => setState(() {
                  isLogin = !isLogin;
                  usernameController.clear();
                  passwordController.clear();
                }),
                child: Text(isLogin ? 'Criar conta' : 'Já tenho conta'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
