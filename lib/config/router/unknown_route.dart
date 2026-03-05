import 'package:flutter/material.dart';
import '../app_helper/app_extension.dart';

class UnknownRoute extends StatelessWidget {
  const UnknownRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        height: context.height,
        width: context.width,
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.warning, size: 150),
            Text('Page Not Found'),
            Text('You missed your way !!'),
          ],
        ),
      ),
    );
  }
}
