import 'package:flutter/material.dart';
import 'package:task_app/app_themes.dart';

class ThemedScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;

  const ThemedScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.floatingActionButton,
    this.bottomNavigationBar,
  });

  @override
  Widget build(BuildContext context) {
    final gradient = Theme.of(context).extension<ThemeGradients>()?.scaffold;
    return Scaffold(
      appBar: appBar,
      body: Container(decoration: BoxDecoration(gradient: gradient), child: body),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}