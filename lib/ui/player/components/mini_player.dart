import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harmonymusic/ui/screens/Settings/settings_screen_controller.dart';
import 'package:ionicons/ionicons.dart';
import 'package:widget_marquee/widget_marquee.dart';

import '/ui/widgets/lyrics_dialog.dart';
import '/ui/widgets/song_info_dialog.dart';
import '/ui/player/player_controller.dart';
import '/ui/themes/modern_button_theme.dart';
import '../../widgets/add_to_playlist.dart';
import '../../widgets/sleep_timer_bottom_sheet.dart';
import '../../widgets/song_download_btn.dart';
import '../../widgets/image_widget.dart';
import '../../widgets/mini_player_progress_bar.dart';
import 'animated_play_button.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final playerController = Get.find<PlayerController>();
    final size = MediaQuery.of(context).size;
    final isWideScreen = size.width > 800;
    final bottomNavEnabled = Get.find<SettingsScreenController>().isBottomNavBarEnabled.isTrue;
    return Obx(() {
      return Visibility(
        visible: playerController.isPlayerpanelTopVisible.value,
        child: AnimatedOpacity(
          opacity: playerController.playerPaneOpacity.value,
          duration: Duration.zero,
          child: Container(
            height: playerController.playerPanelMinHeight.value,
            width: size.width,
            color: Theme.of(context).bottomSheetTheme.backgroundColor,
            child: Center(
              child: Column(
                children: [
                  !isWideScreen || bottomNavEnabled
                      ? GetX<PlayerController>(
                          builder: (controller) => Container(
                              height: 3,
                              color: Theme.of(context)
                                  .progressIndicatorTheme
                                  .color,
                              child: MiniPlayerProgressBar(
                                  progressBarStatus:
                                      controller.progressBarStatus.value,
                                  progressBarColor: Theme.of(context)
                                          .progressIndicatorTheme
                                          .linearTrackColor ??
                                      Colors.white)),
                        )
                      : GetX<PlayerController>(builder: (controller) {
                          return Padding(
                            padding: const EdgeInsets.only(
                                left: 15.0, top: 8, right: 15, bottom: 0),
                            child: ProgressBar(
                              timeLabelLocation: TimeLabelLocation.sides,
                              thumbRadius: 7,
                              barHeight: 4,
                              thumbGlowRadius: 15,
                              baseBarColor: Theme.of(context)
                                  .sliderTheme
                                  .inactiveTrackColor,
                              bufferedBarColor: Theme.of(context)
                                  .sliderTheme
                                  .valueIndicatorColor,
                              progressBarColor: Theme.of(context)
                                  .sliderTheme
                                  .activeTrackColor,
                              thumbColor:
                                  Theme.of(context).sliderTheme.thumbColor,
                              timeLabelTextStyle:
                                  Theme.of(context).textTheme.titleMedium,
                              progress:
                                  controller.progressBarStatus.value.current,
                              total: controller.progressBarStatus.value.total,
                              buffered:
                                  controller.progressBarStatus.value.buffered,
                              onSeek: controller.seek,
                            ),
                          );
                        }),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 17.0, vertical: 7),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            playerController.currentSong.value != null
                                ? ImageWidget(
                                    size: 50,
                                    song: playerController.currentSong.value!,
                                  )
                                : const SizedBox(
                                    height: 50,
                                    width: 50,
                                  ),
                          ],
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: GestureDetector(
                            onHorizontalDragEnd: (DragEndDetails details) {
                              if (details.primaryVelocity! < 0) {
                                playerController.next();
                              } else if (details.primaryVelocity! > 0) {
                                playerController.prev();
                              }
                            },
                            onTap: () {
                              playerController.playerPanelController.open();
                            },
                            child: ColoredBox(
                              color: Colors.transparent,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    height: 20,
                                    child: Text(
                                      playerController.currentSong.value != null
                                          ? playerController
                                              .currentSong.value!.title
                                          : "",
                                      maxLines: 1,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 20,
                                    child: Marquee(
                                      id: "${playerController.currentSong.value}_mini",
                                      delay: const Duration(milliseconds: 300),
                                      duration: const Duration(seconds: 5),
                                      child: Text(
                                        playerController.currentSong.value !=
                                                null
                                            ? playerController
                                                .currentSong.value!.artist!
                                            : "",
                                        maxLines: 1,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        //player control
                        SizedBox(
                          width: isWideScreen && !bottomNavEnabled ? 450 : 90,
                          child: Padding(
                            padding: EdgeInsets.zero,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                if (isWideScreen && !bottomNavEnabled)
                                  Row(
                                    children: [
                                      Obx(() => ModernButtonTheme.modernIconButton(
                                            icon: playerController.isCurrentSongFav.isFalse
                                                ? Icons.favorite_border
                                                : Icons.favorite,
                                            onPressed: playerController.toggleFavourite,
                                            context: context,
                                            color: playerController.isCurrentSongFav.isTrue
                                                ? Colors.red
                                                : Theme.of(context).textTheme.titleMedium!.color,
                                            isSelected: playerController.isCurrentSongFav.isTrue,
                                            tooltip: 'Favoris',
                                            size: 15,
                                          )),
                                      const SizedBox(width: 12),
                                      Obx(() => ModernButtonTheme.modernIconButton(
                                            icon: Ionicons.shuffle,
                                            onPressed: playerController.toggleShuffleMode,
                                            context: context,
                                            color: playerController.isShuffleModeEnabled.value
                                                ? Theme.of(context).colorScheme.primary
                                                : Theme.of(context)
                                                    .textTheme
                                                    .titleLarge!
                                                    .color!
                                                    .withValues(alpha: 0.6),
                                            isSelected: playerController.isShuffleModeEnabled.value,
                                            tooltip: 'Lecture aléatoire',
                                            size: 15,
                                          )),
                                    ],
                                  ),
                                if (isWideScreen && !bottomNavEnabled) const SizedBox(width: 12),
                                // Core controls repositioned with Stack to top-left, center, bottom-right
                                Expanded(
                                  child: SizedBox(
                                    height: 70,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Align(
                                          alignment: Alignment.topLeft,
                                          child: SizedBox(
                                            width: 40,
                                            child: ModernButtonTheme.modernIconButton(
                                              icon: Icons.skip_previous,
                                              onPressed: (playerController.currentQueue.isEmpty ||
                                                      (playerController.currentQueue.first.id ==
                                                          playerController.currentSong.value?.id))
                                                  ? null
                                                  : playerController.prev,
                                              context: context,
                                              color: Theme.of(context).textTheme.titleMedium!.color,
                                              tooltip: 'Précédent',
                                              size: 30,
                                            ),
                                          ),
                                        ),
                                        Align(
                                          alignment: Alignment.center,
                                          child: (isWideScreen && !bottomNavEnabled)
                                              ? ModernButtonTheme.modernPlayButton(
                                                  child: AnimatedPlayButton(
                                                    iconSize: isWideScreen ? 38 : 30,
                                                  ),
                                                  onPressed: null,
                                                  context: context,
                                                  size: 50,
                                                )
                                              : SizedBox.square(
                                                  dimension: 45,
                                                  child: ModernButtonTheme.modernPlayButton(
                                                    child: AnimatedPlayButton(
                                                      iconSize: isWideScreen ? 38 : 30,
                                                    ),
                                                    onPressed: null,
                                                    context: context,
                                                    size: 45,
                                                  )),
                                        ),
                                        Align(
                                          alignment: Alignment.bottomRight,
                                          child: SizedBox(
                                            width: 40,
                                            child: Obx(() {
                                              final isLastSong = playerController.currentQueue.isEmpty ||
                                                  (!(playerController.isShuffleModeEnabled.isTrue ||
                                                          playerController.isQueueLoopModeEnabled.isTrue) &&
                                                      (playerController.currentQueue.last.id ==
                                                          playerController.currentSong.value?.id));
                                              return ModernButtonTheme.modernIconButton(
                                                icon: Icons.skip_next,
                                                onPressed: isLastSong ? null : playerController.next,
                                                context: context,
                                                color: isLastSong
                                                    ? Theme.of(context)
                                                        .textTheme
                                                        .titleLarge!
                                                        .color!
                                                        .withValues(alpha: 0.3)
                                                    : Theme.of(context).textTheme.titleMedium!.color,
                                                tooltip: 'Suivant',
                                                size: 30,
                                              );
                                            }),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                if (isWideScreen && !bottomNavEnabled) const SizedBox(width: 12),
                                if (isWideScreen && !bottomNavEnabled)
                                  Row(
                                    children: [
                                      IconButton(
                                        iconSize: 20,
                                        onPressed: playerController.toggleLoopMode,
                                        icon: Icon(
                                          Icons.all_inclusive,
                                          color: playerController.isLoopModeEnabled.value
                                              ? Theme.of(context).textTheme.titleLarge!.color
                                              : Theme.of(context)
                                                  .textTheme
                                                  .titleLarge!
                                                  .color!
                                                  .withValues(alpha: 0.2),
                                        ),
                                      ),
                                      ModernButtonTheme.modernIconButton(
                                        context: context,
                                        iconSize: 20,
                                        onPressed: () {
                                          playerController.showLyrics();
                                          showDialog(
                                                  builder: (context) => const LyricsDialog(),
                                                  context: context)
                                              .whenComplete(() {
                                            playerController.isDesktopLyricsDialogOpen = false;
                                            playerController.showLyricsflag.value = false;
                                          });
                                          playerController.isDesktopLyricsDialogOpen = true;
                                        },
                                        icon: Icons.lyrics_outlined,
                                        color: Theme.of(context).textTheme.titleLarge!.color,
                                      )
                                    ],
                                  ),
                                if (isWideScreen && !bottomNavEnabled)
                                  const SizedBox(
                                    width: 20,
                                  )
                              ],
                            ),
                          ),
                        ),
                        ),
                        if (isWideScreen && !bottomNavEnabled)
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                  right: size.width < 1004 ? 0 : 30.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.only(
                                        right: 20, left: 10),
                                    height: 20,
                                    width: (size.width > 860) ? 220 : 180,
                                    child: Obx(() {
                                      final volume =
                                          playerController.volume.value;
                                      return Row(
                                        children: [
                                          SizedBox(
                                              width: 20,
                                              child: InkWell(
                                                onTap: playerController.mute,
                                                child: Icon(
                                                  volume == 0
                                                      ? Icons.volume_off
                                                      : volume > 0 &&
                                                              volume < 50
                                                          ? Icons.volume_down
                                                          : Icons.volume_up,
                                                  size: 20,
                                                ),
                                              )),
                                          Expanded(
                                            child: SliderTheme(
                                              data: SliderTheme.of(context)
                                                  .copyWith(
                                                trackHeight: 2,
                                                thumbShape:
                                                    const RoundSliderThumbShape(
                                                        enabledThumbRadius:
                                                            6.0),
                                                overlayShape:
                                                    const RoundSliderOverlayShape(
                                                        overlayRadius: 10.0),
                                              ),
                                              child: Slider(
                                                value: playerController
                                                        .volume.value /
                                                    100,
                                                onChanged: (value) {
                                                  playerController.setVolume(
                                                      (value * 100).toInt());
                                                },
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    }),
                                  ),
                                  SizedBox(
                                    height: 40,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        // Groupe des boutons principaux avec espacement amélioré
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              if (size.width > 860)
                                                ModernButtonTheme.modernIconButton(
                                                  icon: playerController.isSleepTimerActive.isTrue
                                                      ? Icons.timer
                                                      : Icons.timer_outlined,
                                                  onPressed: () {
                                                    showModalBottomSheet(
                                                      constraints: const BoxConstraints(maxWidth: 500),
                                                      shape: const RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.vertical(
                                                            top: Radius.circular(10.0)),
                                                      ),
                                                      isScrollControlled: true,
                                                      context: playerController
                                                          .homeScaffoldkey.currentState!.context,
                                                      barrierColor: Colors.transparent.withAlpha(100),
                                                      builder: (context) => const SleepTimerBottomSheet(),
                                                    );
                                                  },
                                                  context: context,
                                                  color: Theme.of(context).textTheme.titleMedium!.color,
                                                  tooltip: 'Minuteur de veille',
                                                  size: 22,
                                                ),
                                              if (size.width > 860)
                                                const SizedBox(width: 8),
                                              const SongDownloadButton(calledFromPlayer: true),
                                              const SizedBox(width: 8),
                                              ModernButtonTheme.modernIconButton(
                                                icon: Icons.playlist_add,
                                                onPressed: () {
                                                  final currentSong = playerController.currentSong.value;
                                                  if (currentSong != null) {
                                                    showDialog(
                                                      context: context,
                                                      builder: (context) => AddToPlaylist([currentSong]),
                                                    ).whenComplete(() => Get.delete<AddToPlaylistController>());
                                                  }
                                                },
                                                context: context,
                                                color: Theme.of(context).textTheme.titleMedium!.color,
                                                tooltip: 'Ajouter à une playlist',
                                                size: 22,
                                              ),
                                              if (size.width > 965) const SizedBox(width: 8),
                                              if (size.width > 965)
                                                ModernButtonTheme.modernIconButton(
                                                  icon: Icons.info,
                                                  onPressed: () {
                                                    final currentSong = playerController.currentSong.value;
                                                    if (currentSong != null) {
                                                      showDialog(
                                                        context: context,
                                                        builder: (context) => SongInfoDialog(song: currentSong),
                                                      );
                                                    }
                                                  },
                                                  context: context,
                                                  color: Theme.of(context).textTheme.titleMedium!.color,
                                                  tooltip: 'Informations sur la chanson',
                                                  size: 22,
                                                ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        // Bouton de file d'attente séparé
                                        ModernButtonTheme.modernIconButton(
                                          icon: Icons.queue_music,
                                          onPressed: () {
                                            playerController.homeScaffoldkey.currentState!.openEndDrawer();
                                          },
                                          context: context,
                                          color: Theme.of(context).textTheme.titleMedium!.color,
                                          tooltip: 'File d\'attente',
                                          size: 22,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
