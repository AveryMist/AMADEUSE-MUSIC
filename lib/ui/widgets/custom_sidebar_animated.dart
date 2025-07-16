import 'package:flutter/material.dart';
import 'package:sidebar_with_animation/animated_side_bar.dart';
import 'rounded_logo_widget.dart';

/// Custom wrapper for SideBarAnimated that uses our RoundedLogoWidget
/// instead of the default logo display
class CustomSideBarAnimated extends StatelessWidget {
  const CustomSideBarAnimated({
    super.key,
    required this.onTap,
    required this.sideBarColor,
    required this.animatedContainerColor,
    required this.hoverColor,
    required this.splashColor,
    required this.highlightColor,
    required this.widthSwitch,
    required this.sidebarItems,
  });

  final Function(int) onTap;
  final Color sideBarColor;
  final Color animatedContainerColor;
  final Color hoverColor;
  final Color splashColor;
  final Color highlightColor;
  final double widthSwitch;
  final List<SideBarItem> sidebarItems;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Original SideBarAnimated without logo
        SideBarAnimated(
          onTap: onTap,
          sideBarColor: sideBarColor,
          animatedContainerColor: animatedContainerColor,
          hoverColor: hoverColor,
          splashColor: splashColor,
          highlightColor: highlightColor,
          widthSwitch: widthSwitch,
          mainLogoImage: '', // Empty to hide default logo
          sidebarItems: sidebarItems,
        ),
        // Custom rounded logo overlay
        Positioned(
          top: 20,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(8.0),
              child: const RoundedLogoWidget(
                size: 50,
                borderRadius: 12.0,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
