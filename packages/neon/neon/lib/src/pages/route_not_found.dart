import 'dart:async';

import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:neon/l10n/localizations.dart';
import 'package:neon/src/blocs/accounts.dart';
import 'package:neon/src/router.dart';
import 'package:neon/src/utils/provider.dart';
import 'package:url_launcher/url_launcher.dart';

@internal
class RouteNotFoundPage extends StatefulWidget {
  const RouteNotFoundPage({
    required this.uri,
    super.key,
  });

  final Uri uri;

  @override
  State<RouteNotFoundPage> createState() => _RouteNotFoundPageState();
}

class _RouteNotFoundPageState extends State<RouteNotFoundPage> {
  @override
  void initState() {
    super.initState();

    unawaited(_checkLaunchable());
  }

  Future<void> _checkLaunchable() async {
    final accountsBloc = NeonProvider.of<AccountsBloc>(context);
    if (!accountsBloc.hasAccounts) {
      return;
    }

    final activeAccount = accountsBloc.activeAccount.value!;

    final launched = await launchUrl(
      activeAccount.completeUri(widget.uri),
      mode: LaunchMode.externalApplication,
    );
    if (!launched) {
      return;
    }

    if (context.mounted) {
      const HomeRoute().go(context);
    }
  }

  @override
  Widget build(final BuildContext context) => Scaffold(
        appBar: AppBar(
          leading: CloseButton(
            onPressed: () {
              const HomeRoute().go(context);
            },
          ),
        ),
        body: Center(
          child: Text(AppLocalizations.of(context).errorRouteNotFound(widget.uri.toString())),
        ),
      );
}
