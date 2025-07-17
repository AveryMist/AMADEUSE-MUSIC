import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harmonymusic/ui/screens/Home/home_screen_controller.dart';
import 'package:sidebar_with_animation/animated_side_bar.dart';
import 'custom_sidebar_animated.dart';
import 'modern_floating_sidebar.dart';

class SideNavBar extends StatelessWidget {
  const SideNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    // Retourner la nouvelle barre latérale flottante moderne
    return const Stack(
      children: [
        ModernFloatingSidebar(),
      ],
    );
  }

  NavigationRailDestination railDestination(
      String label, bool isMobileOrTabScreen, IconData icon) {
    return isMobileOrTabScreen
        ? NavigationRailDestination(
            icon: const SizedBox.shrink(),
            label: Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: isMobileOrTabScreen
                    ? RotatedBox(quarterTurns: -1, child: Text(label))
                    : Text(label)),
          )
        : NavigationRailDestination(
            icon: Icon(icon),
            label: Text(label),
            padding: const EdgeInsets.only(left: 10),
            indicatorShape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10))),
            indicatorColor: Colors.amber);
  }
}
