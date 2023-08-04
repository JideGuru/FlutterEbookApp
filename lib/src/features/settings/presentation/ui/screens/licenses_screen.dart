import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class LicensesScreen extends StatelessWidget {
  const LicensesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LicensePage(
      applicationIcon: Image.asset(
        'assets/images/app-icon.png',
        height: 150,
        fit: BoxFit.cover,
      ),
    );
  }
}
