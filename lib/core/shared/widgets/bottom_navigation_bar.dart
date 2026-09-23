import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../themes/app_colors/app_colors.dart';

class AppBottomNavigationBar extends StatelessWidget {
  const AppBottomNavigationBar({
    super.key,
    required this.homeScreen,
    required this.ordersScreen,
    required this.profileScreen,
    this.initialIndex = 0,
  });

  final Widget homeScreen;
  final Widget ordersScreen;
  final Widget profileScreen;
  final int initialIndex;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return PersistentTabView(
      controller: PersistentTabController(initialIndex: initialIndex),
      onTabChanged: (_) {},
      tabs: [
        _tabConfig(homeScreen, l10n.navHome, Icons.home_outlined),
        _tabConfig(ordersScreen, l10n.navOrders, Icons.receipt_long_outlined),
        _tabConfig(profileScreen, l10n.navProfile, Icons.person_outline),
      ],
      navBarBuilder: (navBarConfig) => Style1BottomNavBar(
        navBarConfig: navBarConfig,
        navBarDecoration: const NavBarDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
      ),
      backgroundColor: AppColors.surface,
      handleAndroidBackButtonPress: true,
      resizeToAvoidBottomInset: true,
      stateManagement: true,
    );
  }

  PersistentTabConfig _tabConfig(Widget screen, String title, IconData icon) {
    return PersistentTabConfig(
      screen: screen,
      item: ItemConfig(
        icon: Icon(icon),
        title: title,
        activeForegroundColor: AppColors.primary,
        inactiveForegroundColor: AppColors.grey.shade500,
      ),
    );
  }
}
