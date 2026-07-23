import 'package:flutter/material.dart';

import 'theme.dart';

class KairoApp extends StatelessWidget {
  const KairoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kairo',
      debugShowCheckedModeBanner: false,
      theme: kairoTheme,
      home: const Scaffold(
        body: Center(
          child: Text('Kairo'),
        ),
      ),
    );
  }
}
