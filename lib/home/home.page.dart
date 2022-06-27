import 'package:distributor_client/layout/layout.dart';
import 'package:bmi_b2b_package/bmi_b2b_package.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final configDoc = DocProvider.of<ConfigDoc>(context);
    final userDoc = DocProvider.of<UserDoc>(context);
    final getCompney = configDoc.distributor.call;
    final compneies = userDoc.distributor.values;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text("Home Page")),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.separated(
          itemBuilder: (context, index) {
            final compney = compneies.elementAt(index);
            final info = getCompney(compney.id);
            var preview = compney.messages.last.preview;
            if (preview.length >= 30) {
              preview = "${preview.substring(0, 25)}...";
            }
            return ListTile(
              onTap: () {
                CompneyRoute.goTo(context, compney);
              },
              title: Text((info?.name ?? "Unknown")),
              subtitle: Text(
                preview,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              trailing: Text("${compney.dueAmount} ( ${compney.dueBoxes} )"),
            );
          },
          separatorBuilder: (context, index) {
            return const Divider();
          },
          itemCount: compneies.length,
        ),
      ),
      drawer: const MyDrawer(),
    );
  }
}
