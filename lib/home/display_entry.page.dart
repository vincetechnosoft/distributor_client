import 'package:distributor_client/gateway/init.dart';
import 'package:bmi_b2b_package/bmi_b2b_package.dart';
import 'package:flutter/material.dart';

class DisplayEntryPage extends StatelessWidget {
  const DisplayEntryPage({
    Key? key,
    required this.entry,
    required this.compneyID,
  }) : super(key: key);
  final SoldEntry entry;
  final String compneyID;

  @override
  Widget build(BuildContext context) {
    final productDoc = getProductDoc(context, compneyID);
    return EntryPage(
      entry: entry,
      showOptions: false,
      compneyDoc: null,
      productDoc: productDoc.doc,
    );
  }
}
