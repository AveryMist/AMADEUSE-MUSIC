import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../Search/components/desktop_search_bar.dart';
import '/ui/screens/Search/search_screen_controller.dart';
import '/ui/widgets/animated_screen_transition.dart';
import '../Library/library_combined.dart';

import '../../widgets/floating_particles_background.dart';
import '../Library/library.dart';
import '../Search/search_screen.dart';
import '../Settings/settings_screen_controller.dart';
import '../Settings/settings_screen.dart';
import '/ui/player/player_controller.dart';
import '/ui/widgets/create_playlist_dialog.dart';
import '../../navigator.dart';
import '../../widgets/content_list_widget.dart';
import '../../widgets/quickpickswidget.dart';
import '../../widgets/shimmer_widgets/home_shimmer.dart';
import 'home_screen_controller.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _showNavigationMenu(BuildContext context) {
    final homeScreenController = Get.find<HomeScreenController>();
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 10),
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              _buildMenuItem(context, Icons.home, "home".tr, () {
                 homeScreenController.tabIndex.value = 0;
                 Navigator.pop(context);
               }),
               _buildMenuItem(context, Icons.music_note, "songs".tr, () {
                 homeScreenController.tabIndex.value = 1;
                 Navigator.pop(context);
               }),
               _buildMenuItem(context, Icons.playlist_play, "playlists".tr, () {
                 homeScreenController.tabIndex.value = 2;
                 Navigator.pop(context);
               }),
               _buildMenuItem(context, Icons.album, "albums".tr, () {
                 homeScreenController.tabIndex.value = 3;
                 Navigator.pop(context);
               }),
               _buildMenuItem(context, Icons.person, "artists".tr, () {
                 homeScreenController.tabIndex.value = 4;
                 Navigator.pop(context);
               }),
              _buildMenuItem(context, Icons.settings, "settings".tr, () {
                 Get.to(() => const SettingsScreen());
                 Navigator.pop(context);
               }),
              _buildMenuItem(context, Icons.help, "help".tr, () {
                // Action pour l'aide - à personnaliser selon vos besoins
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("help".tr)),
                );
                Navigator.pop(context);
              }),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMenuItem(BuildContext context, IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).iconTheme.color),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
    );
  }

  @override
  Widget build(BuildContext context) {
    final PlayerController playerController = Get.find<PlayerController>();
    final HomeScreenController homeScreenController =
        Get.find<HomeScreenController>();
    final SettingsScreenController settingsScreenController =
        Get.find<SettingsScreenController>();

    return Scaffold(
        floatingActionButton: Obx(
          () => homeScreenController.tabIndex.value == 2 &&
                  settingsScreenController.isBottomNavBarEnabled.isFalse
              ? Obx(
                  () => Padding(
                    padding: EdgeInsets.only(
                        bottom: playerController.playerPanelMinHeight.value >
                                Get.mediaQuery.padding.bottom
                            ? playerController.playerPanelMinHeight.value -
                                Get.mediaQuery.padding.bottom
                            : playerController.playerPanelMinHeight.value),
                    child: SizedBox(
                      height: 60,
                      width: 60,
                      child: FittedBox(
                        child: FloatingActionButton(
                            focusElevation: 0,
                            shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(14))),
                            elevation: 0,
                            onPressed: () async {
                              showDialog(
                                  context: context,
                                  builder: (context) =>
                                      const CreateNRenamePlaylistPopup());
                            },
                            child: const Icon(Icons.add)),
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
        body: Obx(
          () => FloatingParticlesBackground(
            enabled: settingsScreenController.isBottomNavBarEnabled.isFalse,
            particleCount: 15,
            child: Stack(
              children: <Widget>[
                // Contenu principal
                Obx(() => AnimatedScreenTransition(
                    enabled: settingsScreenController
                        .isTransitionAnimationDisabled.isFalse,
                    resverse: homeScreenController.reverseAnimationtransiton,
                    horizontalTransition:
                        settingsScreenController.isBottomNavBarEnabled.isTrue,
                    child: Center(
                      key: ValueKey<int>(homeScreenController.tabIndex.value),
                      child: const Body(),
                    ))),

                // Boutons de navigation en bas à droite
                if (homeScreenController.tabIndex.value == 0 && !GetPlatform.isDesktop && settingsScreenController.isBottomNavBarEnabled.isFalse)
                  Positioned(
                    bottom: 20,
                    right: 20,
                    child: Obx(
                      () => Padding(
                        padding: EdgeInsets.only(
                            bottom: playerController.playerPanelMinHeight.value > 0
                                ? playerController.playerPanelMinHeight.value
                                : 0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Bouton NavNavigation
                            SizedBox(
                              height: 60,
                              width: 60,
                              child: FittedBox(
                                child: FloatingActionButton(
                                  heroTag: "navNavigation",
                                  focusElevation: 0,
                                  shape: const RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(14))),
                                  elevation: 0,
                                  onPressed: () {
                                    _showNavigationMenu(context);
                                  },
                                  child: const Icon(Icons.menu),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            // Bouton de recherche
                            SizedBox(
                              height: 60,
                              width: 60,
                              child: FittedBox(
                                child: FloatingActionButton(
                                  heroTag: "search",
                                  focusElevation: 0,
                                  shape: const RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(14))),
                                  elevation: 0,
                                  onPressed: () {
                                    Get.toNamed(ScreenNavigationSetup.searchScreen,
                                        id: ScreenNavigationSetup.id);
                                  },
                                  child: const Icon(Icons.search),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ));
  }
}

class Body extends StatelessWidget {
  const Body({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final homeScreenController = Get.find<HomeScreenController>();
    final settingsScreenController = Get.find<SettingsScreenController>();
    final size = MediaQuery.of(context).size;
    final topPadding = GetPlatform.isDesktop
        ? 95.0  // Increased padding for better desktop layout
        : context.isLandscape
            ? 50.0
            : size.height < 750
                ? 80.0
                : 85.0;
    final leftPadding =
        settingsScreenController.isBottomNavBarEnabled.isTrue ? 20.0 : 5.0;
    if (homeScreenController.tabIndex.value == 0) {
      return Padding(
        padding: EdgeInsets.only(left: leftPadding),
        child: Stack(
          children: [
            GestureDetector(
              onTap: () {
                // for Desktop search bar
                if (GetPlatform.isDesktop) {
                  final sscontroller = Get.find<SearchScreenController>();
                  if (sscontroller.focusNode.hasFocus) {
                    sscontroller.focusNode.unfocus();
                  }
                }
              },
              child: Obx(
                () => homeScreenController.networkError.isTrue
                    ? SizedBox(
                        height: MediaQuery.of(context).size.height - 180,
                        child: Column(
                          children: [
                            Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                "home".tr,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ),
                            Expanded(
                              child: Center(
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "networkError1".tr,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium,
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 15, vertical: 10),
                                        decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .textTheme
                                                .titleLarge!
                                                .color,
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        child: InkWell(
                                          onTap: () {
                                            homeScreenController
                                                .loadContentFromNetwork();
                                          },
                                          child: Text(
                                            "retry".tr,
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .canvasColor),
                                          ),
                                        ),
                                      ),
                                    ]),
                              ),
                            )
                          ],
                        ),
                      )
                    : Obx(() {
                        // dispose all detachached scroll controllers
                        homeScreenController.disposeDetachedScrollControllers();
                        final items = homeScreenController
                                .isContentFetched.value
                            ? [
                                Obx(() {
                                  final scrollController = ScrollController();
                                  homeScreenController.contentScrollControllers
                                      .add(scrollController);
                                  return QuickPicksWidget(
                                      content:
                                          homeScreenController.quickPicks.value,
                                      scrollController: scrollController);
                                }),
                                // Autres sections (influencées par Set Discover Content)
                                ...getWidgetList(
                                    homeScreenController.middleContent,
                                    homeScreenController),
                                ...getWidgetList(
                                    homeScreenController.fixedContent,
                                    homeScreenController)
                              ]
                            : [const HomeShimmer()];
                        return ListView.builder(
                          padding:
                              EdgeInsets.only(bottom: 200, top: topPadding),
                          itemCount: items.length,
                          itemBuilder: (context, index) => items[index],
                        );
                      }),
              ),
            ),
            if (GetPlatform.isDesktop)
              Align(
                alignment: Alignment.topCenter,
                child: LayoutBuilder(builder: (context, constraints) {
                  return Container(
                    width: constraints.maxWidth > 900
                        ? 900
                        : constraints.maxWidth - 60,
                    margin: const EdgeInsets.only(top: 20.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const DesktopSearchBar(),
                  );
                }),
              )
          ],
        ),
      );
    } else if (homeScreenController.tabIndex.value == 1) {
      return settingsScreenController.isBottomNavBarEnabled.isTrue
          ? const SearchScreen()
          : const SongsLibraryWidget();
    } else if (homeScreenController.tabIndex.value == 2) {
      return settingsScreenController.isBottomNavBarEnabled.isTrue
          ? const CombinedLibrary()
          : const PlaylistNAlbumLibraryWidget(isAlbumContent: false);
    } else if (homeScreenController.tabIndex.value == 3) {
      return settingsScreenController.isBottomNavBarEnabled.isTrue
          ? const SettingsScreen(isBottomNavActive: true)
          : const PlaylistNAlbumLibraryWidget();
    } else if (homeScreenController.tabIndex.value == 4) {
      return const LibraryArtistWidget();
    } else if (homeScreenController.tabIndex.value == 5) {
      return const SettingsScreen();
    } else {
      return Center(
        child: Text("${homeScreenController.tabIndex.value}"),
      );
    }
  }

  List<Widget> getWidgetList(
      dynamic list, HomeScreenController homeScreenController) {
    return list
        .map((content) {
          final scrollController = ScrollController();
          homeScreenController.contentScrollControllers.add(scrollController);
          return ContentListWidget(
              content: content, scrollController: scrollController);
        })
        .whereType<Widget>()
        .toList();
  }
}
