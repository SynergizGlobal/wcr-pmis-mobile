import 'package:flutter/material.dart';

class RfiPage extends StatelessWidget {
  const RfiPage({super.key});

  static const String routeName = 'rfi';
  static const String routePath = '/rfi';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('RFI')),
      body: const SafeArea(
        child: Center(
          child: Text('RFI screen is ready for integration.'),
        ),
      ),
    );
  }
}
