import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harmonymusic/ui/screens/Home/home_screen_controller.dart';
import 'package:sidebar_with_animation/animated_side_bar.dart';

class SideNavBar extends StatelessWidget {
  const SideNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobileOrTabScreen = size.width < 480;
    final homeScreenController = Get.find<HomeScreenController>();
    return Align(
      alignment: Alignment.topCenter,
      child: isMobileOrTabScreen
          ? SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 80),
              child: IntrinsicHeight(
                child: Obx(
                  () => NavigationRail(
                    useIndicator: !isMobileOrTabScreen,
                    selectedIndex:
                        homeScreenController.tabIndex.value, //_selectedIndex,
                    onDestinationSelected:
                        homeScreenController.onSideBarTabSelected,
                    minWidth: 76,
                    leading: SizedBox(height: size.height < 750 ? 45 : 85),
                    minExtendedWidth: 290,
                    extended: !isMobileOrTabScreen,
                    labelType: isMobileOrTabScreen
                        ? NavigationRailLabelType.all
                        : NavigationRailLabelType.none,
                    //backgroundColor: Colors.green,
                    destinations: <NavigationRailDestination>[
                      railDestination(
                          "home".tr, isMobileOrTabScreen, Icons.home_outlined, Icons.home),
                      railDestination(
                          "songs".tr, isMobileOrTabScreen, Icons.music_note_outlined, Icons.music_note),
                      railDestination("playlists".tr, isMobileOrTabScreen,
                          Icons.playlist_play_outlined, Icons.playlist_play),
                      railDestination(
                          "albums".tr, isMobileOrTabScreen, Icons.album_outlined, Icons.album),
                      railDestination(
                          "artists".tr, isMobileOrTabScreen, Icons.person_outline, Icons.person),
                      NavigationRailDestination(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        icon: const Icon(Icons.settings_outlined),
                        label: const SizedBox.shrink(),
                        selectedIcon: const Icon(Icons.settings),
                      )
                    ],
                  ),
                ),
              ))
          : Padding(
              padding: const EdgeInsets.only(bottom: 100.0),
              child: SideBarAnimated(
                onTap: homeScreenController.onSideBarTabSelected,
                sideBarColor: Theme.of(context).colorScheme.surface.withOpacity(0.95),
                animatedContainerColor: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.8),
                hoverColor:
                    Theme.of(context).colorScheme.primaryContainer.withOpacity(0.6),
                splashColor: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                highlightColor:
                    Theme.of(context).colorScheme.primaryContainer.withOpacity(0.4),
                widthSwitch: 800,
                mainLogoImage: 'assets/icons/icon.png',
                sidebarItems: [
                  SideBarItem(
                    iconSelected: Icons.home,
                    iconUnselected: Icons.home_outlined,
                    text: 'home'.tr,
                  ),
                  SideBarItem(
                    iconSelected: Icons.music_note,
                    iconUnselected: Icons.music_note_outlined,
                    text: 'songs'.tr,
                  ),
                  SideBarItem(
                    iconSelected: Icons.playlist_play,
                    iconUnselected: Icons.playlist_play_outlined,
                    text: 'playlists'.tr,
                  ),
                  SideBarItem(
                    iconSelected: Icons.album,
                    iconUnselected: Icons.album_outlined,
                    text: 'albums'.tr,
                  ),
                  SideBarItem(
                    iconSelected: Icons.person,
                    iconUnselected: Icons.person_outline,
                    text: 'artists'.tr,
                  ),
                  SideBarItem(
                    iconSelected: Icons.settings,
                    iconUnselected: Icons.settings_outlined,
                    text: 'settings'.tr,
                  ),
                ],
              ),
            ),
    );
  }

  NavigationRailDestination railDestination(
      String label, bool isMobileOrTabScreen, IconData unselectedIcon, [IconData? selectedIcon]) {
    return isMobileOrTabScreen
        ? NavigationRailDestination(
            icon: const SizedBox.shrink(),
            label: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: isMobileOrTabScreen
                    ? RotatedBox(quarterTurns: -1, child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)))
                    : Text(label)),
          )
        : NavigationRailDestination(
            icon: Icon(unselectedIcon),
            selectedIcon: selectedIcon != null ? Icon(selectedIcon) : Icon(unselectedIcon),
            label: Text(label),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            indicatorShape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12))),
            indicatorColor: Colors.transparent);
  }
}
