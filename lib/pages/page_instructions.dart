import 'package:flutter/material.dart';

class InstructionsPage extends StatelessWidget {
  const InstructionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kullanım Kılavuzu'), centerTitle: true,
      ),
      body: const Center(
        child: Text('Bu sayfa uygulamanın kullanım kılavuzudur.'),
      ),
    );
  }
}
