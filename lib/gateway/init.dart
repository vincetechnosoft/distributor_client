import 'package:distributor_client/main.dart';
import 'package:bmi_b2b_package/bmi_b2b_package.dart';

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

class InitGateWay extends StatelessWidget {
  const InitGateWay.builder(this.child, {Key? key}) : super(key: key);
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => DocProvider(
                parse: ConfigDoc.fromJson, initialPath: "CONFIG/DISTRIBUTOR")),
        ChangeNotifierProxyProvider<MyAuthUser, DocProvider<UserDoc>>(
          create: (_) => DocProvider(parse: UserDoc.fromJson),
          update: (_, user, doc) {
            doc ??= DocProvider(parse: UserDoc.fromJson);
            doc.changePath("USERS/${user.uid}");
            return doc;
          },
        ),
        ChangeNotifierProvider(
          create: (_) => MultiDoc(parse: ProductDoc.fromJson),
        ),
      ],
      child: child,
    );
  }
}

FetchStaticFirebaseDoc<ProductDoc> getProductDoc(
  BuildContext context,
  String compneyID,
) {
  return MultiDoc.of<ProductDoc>(
      context, "DISTRIBUTOR/$compneyID/DATA/PRODUCTS");
}
