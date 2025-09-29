import 'package:flutter/material.dart';
import 'package:n1/login_page.dart';

class Onboarding extends StatefulWidget {
  const Onboarding({Key? key}) : super(key: key);

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  int stage = 0;

  void next() {
    if (stage < 2) {
      setState(() => stage++);
    } else {
      skip();
    }
  }

  void back() {
    setState(() => stage--);
  }

  void skip() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [TextButton(onPressed: skip, child: const Text('Pular'))],
      ),
      body: Column(
        children: [
          Expanded(
            child: [
              const StageOne(),
              const StageTwo(),
              const StageThree(),
            ][stage],
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (stage > 0)
                  OutlinedButton(onPressed: back, child: const Text('Voltar'))
                else
                  const SizedBox(),
                FilledButton(
                  onPressed: next,
                  child: Text(stage < 2 ? 'Próximo' : 'Começar'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class StageOne extends StatelessWidget {
  const StageOne({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.task_alt, size: 100, color: Colors.blue),
            SizedBox(height: 40),
            Text(
              'Gerenciar Tarefas',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              'Crie e organize suas tarefas de forma simples',
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class StageTwo extends StatelessWidget {
  const StageTwo({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.repeat, size: 100, color: Colors.blue),
            SizedBox(height: 40),
            Text(
              'Criar Rotinas',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              'Estabeleça rotinas e hábitos recorrentes',
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class StageThree extends StatelessWidget {
  const StageThree({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.category, size: 100, color: Colors.blue),
            SizedBox(height: 40),
            Text(
              'Organizar Categorias',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              'Agrupe suas tarefas em categorias personalizadas',
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
