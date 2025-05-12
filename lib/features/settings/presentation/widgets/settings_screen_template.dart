import 'package:flutter/material.dart';
import 'package:flutter_starter_package/core/theme/app_colors.dart';
import 'package:flutter_starter_package/core/widgets/themed_back_button.dart';

class SettingsScreenTemplate extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;

  const SettingsScreenTemplate({
    Key? key,
    required this.title,
    required this.body,
    this.actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const ThemedBackButton(),
        title: Text(title),
        actions: actions,
      ),
      body: SafeArea(
        child: body,
      ),
    );
  }
} 