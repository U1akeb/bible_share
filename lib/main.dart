import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bible_share/get/home_screen.dart';
import 'package:bible_share/get/reflection_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ReflectionProvider()),
      ],
      child: const MaterialApp(
        debugShowCheckedModeBanner: false, 
        home: BibleShare()
      ),
    ),
  );
}

class BibleShare extends StatelessWidget {
  const BibleShare({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomeScreen();
  }
}
