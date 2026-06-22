import 'package:flutter/material.dart';
import 'theme.dart';
import 'repository.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PSEstatutosApp());
}

class PSEstatutosApp extends StatelessWidget {
  const PSEstatutosApp({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = Repository();
    return MaterialApp(
      title: 'Estatutos PS',
      debugShowCheckedModeBanner: false,
      theme: buildPSTheme(),
      home: HomeScreen(repo: repo),
    );
  }
}
