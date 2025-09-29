import 'package:flutter/material.dart';
import 'package:n1/auth_provider.dart';
import 'package:n1/home.dart';
import 'package:n1/auth_storage.dart';
import 'package:n1/task_storage.dart';
import 'package:provider/provider.dart';
import 'package:local_auth/local_auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

enum ViewingAs { login, register, recover }

class _LoginPageState extends State<LoginPage> {
  ViewingAs view = ViewingAs.login;
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final LocalAuthentication auth = LocalAuthentication();
  bool biometryVerified = false;

  void handleSubmit() {
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      showMessage('Preencha todos os campos');
      return;
    }

    switch (view) {
      case ViewingAs.login:
        _handleLogin(username, password);
        break;
      case ViewingAs.register:
        _handleRegister(username, password);
        break;
      case ViewingAs.recover:
        _handleRecover(username, password);
        break;
    }
  }

  void _handleLogin(String username, String password) {
    if (AuthStorage.checkLogin(username, password)) {
      context.read<AuthProvider>().login(username);

      TaskStorage.addCategory(
        Category("name", Colors.orange, Icons.abc),
        context,
      );

      TaskStorage.addTask(
        Task(
          "title",
          0,
          description: "dsada",
          isCompleted: false,
          priority: Priority.high,
        ),
        context,
      );

      TaskStorage.addSubTask(
        0,
        Task(
          "title",
          0,
          description: "dsada",
          isCompleted: false,
          priority: Priority.high,
        ),
        context,
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Home()),
      );
    } else {
      showMessage('Usuário ou senha incorretos');
    }
  }

  void _handleRegister(String username, String password) {
    if (AuthStorage.userExists(username)) {
      showMessage('Usuário já existe');
    } else {
      AuthStorage.addUser(username, password);
      showMessage('Usuário cadastrado!');
      setState(() {
        view = ViewingAs.login;
        usernameController.clear();
        passwordController.clear();
      });
    }
  }

  Future<void> _handleRecover(String username, String newPassword) async {
    if (!biometryVerified) {
      showMessage('Autenticação biométrica necessária');
      return;
    }

    if (!AuthStorage.userExists(username)) {
      showMessage('Usuário não encontrado');
      return;
    }

    AuthStorage.updatePassword(username, newPassword);
    showMessage('Senha alterada com sucesso!');
    setState(() {
      view = ViewingAs.login;
      biometryVerified = false;
      usernameController.clear();
      passwordController.clear();
    });
  }

  Future<void> _authenticateBiometry() async {
    try {
      final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
      final bool canAuthenticate =
          canAuthenticateWithBiometrics || await auth.isDeviceSupported();

      if (!canAuthenticate) {
        showMessage('Biometria não disponível neste dispositivo');
        return;
      }

      final bool didAuthenticate = await auth.authenticate(
        localizedReason: 'Autentique-se para recuperar sua senha',
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
        ),
      );

      if (didAuthenticate) {
        setState(() => biometryVerified = true);
        showMessage('Biometria verificada! Agora defina uma nova senha');
      } else {
        showMessage('Autenticação falhou');
      }
    } catch (e) {
      showMessage('Erro na autenticação: $e');
    }
  }

  void showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  String getTitle() {
    switch (view) {
      case ViewingAs.login:
        return 'Bem-vindo!';
      case ViewingAs.register:
        return 'Criar Conta';
      case ViewingAs.recover:
        return 'Recuperar Senha';
    }
  }

  String getButtonLabel() {
    switch (view) {
      case ViewingAs.login:
        return 'Entrar';
      case ViewingAs.register:
        return 'Cadastrar';
      case ViewingAs.recover:
        return 'Alterar Senha';
    }
  }

  String getToggleLabel() {
    switch (view) {
      case ViewingAs.login:
        return 'Criar conta';
      case ViewingAs.register:
        return 'Já tenho conta';
      case ViewingAs.recover:
        return 'Voltar ao login';
    }
  }

  void toggleView() {
    setState(() {
      if (view == ViewingAs.login) {
        view = ViewingAs.register;
      } else {
        view = ViewingAs.login;
      }
      biometryVerified = false;
      usernameController.clear();
      passwordController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    AuthStorage.addUser("aa", "aa");

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                view == ViewingAs.recover
                    ? Icons.fingerprint
                    : Icons.lock_outline,
                size: 80,
                color: Colors.blue,
              ),
              const SizedBox(height: 40),
              Text(
                getTitle(),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),
              if (view == ViewingAs.recover && !biometryVerified)
                Column(
                  children: [
                    const Text(
                      'Primeiro, autentique-se com biometria',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _authenticateBiometry,
                        icon: const Icon(Icons.fingerprint),
                        label: const Text('Autenticar com Biometria'),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              if (view != ViewingAs.recover || biometryVerified) ...[
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
                    labelText: view == ViewingAs.recover
                        ? 'Nova Senha'
                        : 'Senha',
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
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(getButtonLabel()),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: toggleView,
                    child: Text(getToggleLabel()),
                  ),
                  if (view == ViewingAs.login) ...[
                    const Text(' | ', style: TextStyle(color: Colors.grey)),
                    TextButton(
                      onPressed: () => setState(() {
                        view = ViewingAs.recover;
                        biometryVerified = false;
                        usernameController.clear();
                        passwordController.clear();
                      }),
                      child: const Text('Esqueci a senha'),
                    ),
                  ],
                ],
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
