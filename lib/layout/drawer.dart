import 'package:distributor_client/layout/layout.dart';
import 'package:distributor_client/main.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: const [
          _Header(),
          _PageTo(page: MainPage.home),
          _PageTo(page: MainPage.settings),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<MyAuthUser>(context);
    return DrawerHeader(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            user.isDev == true ? "Developer" : "User",
            style: Theme.of(context).textTheme.headline3,
          ),
          const Spacer(),
          Text(
            user.phoneNumber,
            style: Theme.of(context).textTheme.headline5,
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

class _PageTo extends StatelessWidget {
  const _PageTo({Key? key, required this.page}) : super(key: key);
  final MainPage page;

  @override
  Widget build(BuildContext context) {
    final pathTo = MainRoute.of(page);
    final settings = Provider.of<RouteSettings>(context);
    if (pathTo.route == (settings.name ?? "/")) {
      return ListTile(
        selected: true,
        leading: Icon(pathTo.icon),
        title: Text(pathTo.name),
        onTap: () {
          Navigator.pop(context);
        },
      );
    }
    return ListTile(
      leading: Icon(pathTo.icon),
      title: Text(pathTo.name),
      onTap: () {
        pathTo.navigate(context, argument: null);
      },
    );
  }
}
