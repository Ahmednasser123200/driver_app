import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RefreshWidget extends StatelessWidget {
  const RefreshWidget({
    super.key,
    required this.child,
    required this.onRefresh,
    required this.refreshKey,
  });

  final Widget child;
  final Future<void> Function() onRefresh;
  final GlobalKey<RefreshIndicatorState> refreshKey;

  @override
  Widget build(BuildContext context) {
    return Platform.isAndroid ? buildAndriod() : buildIos();
  }

  Widget buildAndriod() {
    return RefreshIndicator(
      onRefresh: onRefresh,
      key: refreshKey,
      child: child,
    );
  }

  Widget buildIos() {
    return CustomScrollView(
      slivers: [
        CupertinoSliverRefreshControl(onRefresh: onRefresh, key: refreshKey),
        SliverToBoxAdapter(child: child),
      ],
    );
  }
}
