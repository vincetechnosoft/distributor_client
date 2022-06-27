import 'dart:io';

import 'package:distributor_client/firebase_options.dart';
import 'package:distributor_client/gateway/final.dart';
import 'package:distributor_client/gateway/init.dart';
import 'package:distributor_client/layout/layout.dart';
import 'package:bmi_b2b_package/bmi_b2b_package.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';

SharedPreferences? _preferences;
SharedPreferences get preferences => _preferences!;

Directory? _dir;
Directory get dir => _dir!;

PackageInfo? _packageInfo;
Version get currentAppVersion {
  return Version(
    _packageInfo!.version.split("."),
    _packageInfo!.buildNumber,
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseAppCheck.instance.activate();
  _dir = await getApplicationDocumentsDirectory();
  _preferences = await SharedPreferences.getInstance();
  _packageInfo = await PackageInfo.fromPlatform();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BmiApp<MyAuthUser, MainRoute>(
      title: "Distributor Client",
      compneyLifeProvider: CompneyLifeProvider(compneyType: "distributor"),
      appInfoProvider: AppInfoProvider(
        listenNode: "distributor_client",
        appVersion: currentAppVersion,
        apkDir: Directory("${dir.path}/apk"),
      ),
      authProvider: AuthProvider(
        userBuilder: (user) async {
          return MyAuthUser(
            user,
            (await user.getIdTokenResult(true)).claims ?? {},
          );
        },
      ),
      configProvider: ConfigProvider(
        preferences: preferences,
        defaultRoute: MainRoute.defaultRoute,
        initGateway: InitGateWay.builder,
        finalGateway: FinalGateWay.builder,
      ),
    );
  }
}

class MyAuthUser extends B2bAuthUser {
  MyAuthUser(super.user, super.claims);
  @override
  String? get compneyIdInUse => null;
}
