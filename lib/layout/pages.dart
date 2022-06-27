import 'package:distributor_client/home/home.page.dart';
import 'package:distributor_client/home/compney.page.dart';
import 'package:distributor_client/layout/settings.page.dart';
import 'package:bmi_b2b_package/bmi_b2b_package.dart';
import 'package:flutter/material.dart';

enum MainPage { home, settings }

class MainRoute extends AppRoute<void> {
  static MainRoute of(MainPage page) {
    return _routes[page]!;
  }

  static final defaultRoute = MainRoute._(
    icon: Icons.home,
    route: "/",
    name: "Home",
    page: const HomePage(),
  );
  static final _routes = {
    MainPage.home: defaultRoute,
    MainPage.settings: MainRoute._(
      icon: Icons.settings,
      route: "/settings",
      name: "Settings",
      page: const SettingsPage(),
    ),
  };
  static void goTo(BuildContext context, MainPage mainPage) {
    _routes[mainPage]!.navigate(context, argument: null);
  }

  MainRoute._({
    required String route,
    required this.icon,
    required this.name,
    required this.page,
  }) : super(route);

  final IconData icon;
  final String name;
  final Widget page;

  @override
  Widget? builder({argument}) {
    return page;
  }

  @override
  bool get isMainPage => true;
}

class CompneyRoute extends AppRoute<Compney> {
  static void goTo(BuildContext context, Compney compney) {
    _instance.navigate(context, argument: compney);
  }

  static final _instance = CompneyRoute._();
  CompneyRoute._() : super("/home/compney");

  @override
  Widget? builder({required Compney? argument}) {
    if (argument == null) return null;
    return ShopPage(compneyID: argument.id);
  }

  @override
  bool get isMainPage => false;
}
