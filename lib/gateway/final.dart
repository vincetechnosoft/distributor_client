import 'package:distributor_client/main.dart';
import 'package:distributor_client/utils/error_page.dart';
import 'package:bmi_b2b_package/bmi_b2b_package.dart';

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

class FinalGateWay extends StatelessWidget {
  const FinalGateWay.builder(this.child, {Key? key}) : super(key: key);
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final configDocProvider = Provider.of<DocProvider<ConfigDoc>>(context);

    final userDocProvider = Provider.of<DocProvider<UserDoc>>(context);

    if (configDocProvider.doc == null || userDocProvider.doc == null) {
      if (configDocProvider.loading || userDocProvider.loading) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Getting Data"),
            actions: [SettingsWidgit.signOut<MyAuthUser>()],
          ),
          body: const Center(child: CircularProgressIndicator()),
        );
      }
      return ErrorPage(
        fromGateWay: true,
        errorObj: userDocProvider.error ?? "Compney Info Document Not Found",
        title: "Server Side Error",
        drawer: false,
      );
    }
    return child;
  }
}
