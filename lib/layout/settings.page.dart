import 'package:distributor_client/layout/drawer.dart';
import 'package:distributor_client/main.dart';
import 'package:bmi_b2b_package/bmi_b2b_package.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MyDrawer(),
      appBar: AppBar(title: const Text("Settings")),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            SettingsWidgit.selectTheme(),
            const Divider(),
            SettingsWidgit.appInfo(),
            const Divider(),
            SettingsWidgit.signOut<MyAuthUser>(),
          ],
        ),
      ),
    );
  }
}
