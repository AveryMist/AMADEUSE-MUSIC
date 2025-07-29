import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart' as material;
import 'package:get/get.dart';
import 'package:amadeusemusic/ui/screens/Settings/settings_screen_controller.dart';
import 'package:ionicons/ionicons.dart';
import 'package:widget_marquee/widget_marquee.dart';

import '/ui/widgets/lyrics_dialog.dart';
import '/ui/widgets/song_info_dialog.dart';
import '/ui/player/player_controller.dart';
import '../../widgets/add_to_playlist.dart';
import '../../widgets/sleep_timer_bottom_sheet.dart';
import '../../widgets/song_download_btn.dart';
import '../../widgets/image_widget.dart';
import '../../widgets/mini_player_progress_bar.dart';
import '../../widgets/desktop_visual_effects.dart';
import '../../utils/theme_controller.dart';
import 'animated_play_button.dart';

class MiniPlayer extends material.StatelessWidget {
  const MiniPlayer({super.key});

  @override
  material.Widget build(material.BuildContext context) {
    final playerController = Get.find<PlayerController>();
    final size = material.MediaQuery.of(context).size;
    final isWideScreen = size.width > 800;
    final bottomNavEnabled =
        Get.find<SettingsScreenController>().isBottomNavBarEnabled.isTrue;
    return Obx(() {
      return material.Visibility(
        visible: playerController.isPlayerpanelTopVisible.value,
        child: material.AnimatedOpacity(
          opacity: playerController.playerPaneOpacity.value,
          duration: Duration.zero,
          child: material.Container(
            height: playerController.playerPanelMinHeight.value,
            width: size.width,
            color: material.Theme.of(context).bottomSheetTheme.backgroundColor,
            child: material.Center(
              child: material.Column(
                children: [
                  !isWideScreen || bottomNavEnabled
                      ? GetX<PlayerController>(
                          builder: (controller) => material.Container(
                              height: 3,
                              color: material.Theme.of(context)
                                  .progressIndicatorTheme
                                  .color,
                              child: MiniPlayerProgressBar(
                                  progressBarStatus:
                                      controller.progressBarStatus.value,
                                  progressBarColor: material.Theme.of(context)
                                          .progressIndicatorTheme
                                          .linearTrackColor ??
                                      material.Colors.white)),
                        )
                      : GetX<PlayerController>(builder: (controller) {
                          return material.Padding(
                            padding: const material.EdgeInsets.only(
                                left: 15.0, top: 8, right: 15, bottom: 0),
                            child: ProgressBar(
                              timeLabelLocation: TimeLabelLocation.sides,
                              thumbRadius: 7,
                              barHeight: 4,
                              thumbGlowRadius: 15,
                              baseBarColor: material.Theme.of(context)
                                  .sliderTheme
                                  .inactiveTrackColor,
                              bufferedBarColor: material.Theme.of(context)
                                  .sliderTheme
                                  .valueIndicatorColor,
                              progressBarColor: material.Theme.of(context)
                                  .sliderTheme
                                  .activeTrackColor,
                              thumbColor: material.Theme.of(context)
                                  .sliderTheme
                                  .thumbColor,
                              timeLabelTextStyle: material.Theme.of(context)
                                  .textTheme
                                  .titleMedium,
                              progress:
                                  controller.progressBarStatus.value.current,
                              total: controller.progressBarStatus.value.total,
                              buffered:
                                  controller.progressBarStatus.value.buffered,
                              onSeek: controller.seek,
                            ),
                          );
                        }),
                  material.Padding(
                    padding: const material.EdgeInsets.symmetric(
                        horizontal: 17.0, vertical: 7),
                    child: material.Row(
                      mainAxisAlignment:
                          material.MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: material.CrossAxisAlignment.center,
                      children: [
                        material.Row(
                          mainAxisAlignment: material.MainAxisAlignment.start,
                          children: [
                            playerController.currentSong.value != null
                                ? GetPlatform.isDesktop
                                    ? GlowEffect(
                                        glowColor: Get.find<ThemeController>()
                                            .primaryColor
                                            .value,
                                        glowRadius: 8.0,
                                        glowOpacity: 0.4,
                                        child: ImageWidget(
                                          size: 50,
                                          song: playerController
                                              .currentSong.value!,
                                        ),
                                      )
                                    : ImageWidget(
                                        size: 50,
                                        song:
                                            playerController.currentSong.value!,
                                      )
                                : const material.SizedBox(
                                    height: 50,
                                    width: 50,
                                  ),
                          ],
                        ),
                        const material.SizedBox(
                          width: 10,
                        ),
                        material.Expanded(
                          child: material.GestureDetector(
                            onHorizontalDragEnd:
                                (material.DragEndDetails details) {
                              if (details.primaryVelocity! < 0) {
                                playerController.next();
                              } else if (details.primaryVelocity! > 0) {
                                playerController.prev();
                              }
                            },
                            onTap: () {
                              playerController.playerPanelController.open();
                            },
                            child: material.ColoredBox(
                              color: material.Colors.transparent,
                              child: material.Column(
                                mainAxisAlignment:
                                    material.MainAxisAlignment.center,
                                crossAxisAlignment:
                                    material.CrossAxisAlignment.start,
                                children: [
                                  material.SizedBox(
                                    height: 20,
                                    child: material.Text(
                                      playerController.currentSong.value != null
                                          ? playerController
                                              .currentSong.value!.title
                                          : "",
                                      maxLines: 1,
                                      style: material.Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                    ),
                                  ),
                                  material.SizedBox(
                                    height: 20,
                                    child: Marquee(
                                      id: "${playerController.currentSong.value}_mini",
                                      delay: const Duration(milliseconds: 300),
                                      duration: const Duration(seconds: 5),
                                      child: material.Text(
                                        playerController.currentSong.value !=
                                                null
                                            ? playerController
                                                .currentSong.value!.artist!
                                            : "",
                                        maxLines: 1,
                                        style: material.Theme.of(context)
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
                        material.SizedBox(
                          width: isWideScreen && !bottomNavEnabled ? 450 : 90,
                          child: material.Row(
                            mainAxisAlignment:
                                material.MainAxisAlignment.spaceEvenly,
                            children: [
                              if (isWideScreen && !bottomNavEnabled)
                                material.Row(
                                  children: [
                                    material.IconButton(
                                        iconSize: 20,
                                        onPressed:
                                            playerController.toggleFavourite,
                                        icon: Obx(() => material.Icon(
                                              playerController
                                                      .isCurrentSongFav.isFalse
                                                  ? material
                                                      .Icons.favorite_border
                                                  : material.Icons.favorite,
                                              color: material.Theme.of(context)
                                                  .textTheme
                                                  .titleMedium!
                                                  .color,
                                            ))),
                                    material.IconButton(
                                        iconSize: 20,
                                        onPressed:
                                            playerController.toggleShuffleMode,
                                        icon: Obx(() => material.Icon(
                                              Ionicons.shuffle,
                                              color: playerController
                                                      .isShuffleModeEnabled
                                                      .value
                                                  ? material.Theme.of(context)
                                                      .textTheme
                                                      .titleLarge!
                                                      .color
                                                  : material.Theme.of(context)
                                                      .textTheme
                                                      .titleLarge!
                                                      .color!
                                                      .withOpacity(0.2),
                                            ))),
                                  ],
                                ),
                              if (isWideScreen && !bottomNavEnabled)
                                material.SizedBox(
                                    width: 40,
                                    child: material.InkWell(
                                      onTap: (playerController
                                                  .currentQueue.isEmpty ||
                                              (playerController
                                                      .currentQueue.first.id ==
                                                  playerController
                                                      .currentSong.value?.id))
                                          ? null
                                          : playerController.prev,
                                      child: material.Icon(
                                        material.Icons.skip_previous,
                                        color: material.Theme.of(context)
                                            .textTheme
                                            .titleMedium!
                                            .color,
                                        size: 35,
                                      ),
                                    )),
                              isWideScreen && !bottomNavEnabled
                                  ? material.Container(
                                      decoration: material.BoxDecoration(
                                          color: material.Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                          borderRadius:
                                              material.BorderRadius.circular(
                                                  10)),
                                      width: 58,
                                      height: 58,
                                      child: material.Center(
                                          child: AnimatedPlayButton()))
                                  : material.SizedBox.square(
                                      dimension: 50,
                                      child: material.Center(
                                          child: AnimatedPlayButton())),
                              material.SizedBox(
                                  width: 40,
                                  child: Obx(() {
                                    final isLastSong =
                                        playerController.currentQueue.isEmpty ||
                                            (!(playerController
                                                        .isShuffleModeEnabled
                                                        .isTrue ||
                                                    playerController
                                                        .isQueueLoopModeEnabled
                                                        .isTrue) &&
                                                (playerController
                                                        .currentQueue.last.id ==
                                                    playerController.currentSong
                                                        .value?.id));
                                    return material.InkWell(
                                      onTap: isLastSong
                                          ? null
                                          : playerController.next,
                                      child: material.Icon(
                                        material.Icons.skip_next,
                                        color: isLastSong
                                            ? material.Theme.of(context)
                                                .textTheme
                                                .titleLarge!
                                                .color!
                                                .withOpacity(0.2)
                                            : material.Theme.of(context)
                                                .textTheme
                                                .titleMedium!
                                                .color,
                                        size: 35,
                                      ),
                                    );
                                  })),
                              if (isWideScreen && !bottomNavEnabled)
                                material.Row(
                                  children: [
                                    material.IconButton(
                                        iconSize: 20,
                                        onPressed:
                                            playerController.toggleLoopMode,
                                        icon: material.Icon(
                                          material.Icons.all_inclusive,
                                          color: playerController
                                                  .isLoopModeEnabled.value
                                              ? material.Theme.of(context)
                                                  .textTheme
                                                  .titleLarge!
                                                  .color
                                              : material.Theme.of(context)
                                                  .textTheme
                                                  .titleLarge!
                                                  .color!
                                                  .withOpacity(0.2),
                                        )),
                                    material.IconButton(
                                        iconSize: 20,
                                        onPressed: () {
                                          playerController.showLyrics();
                                          material
                                              .showDialog(
                                                  builder: (context) =>
                                                      const LyricsDialog(),
                                                  context: context)
                                              .whenComplete(() {
                                            playerController
                                                    .isDesktopLyricsDialogOpen =
                                                false;
                                            playerController
                                                .showLyricsflag.value = false;
                                          });
                                          playerController
                                              .isDesktopLyricsDialogOpen = true;
                                        },
                                        icon: material.Icon(
                                            material.Icons.lyrics_outlined,
                                            color: material.Theme.of(context)
                                                .textTheme
                                                .titleLarge!
                                                .color)),
                                  ],
                                ),
                              if (isWideScreen && !bottomNavEnabled)
                                const material.SizedBox(
                                  width: 20,
                                )
                            ],
                          ),
                        ),
                        if (isWideScreen && !bottomNavEnabled)
                          material.Expanded(
                            child: material.Padding(
                              padding: material.EdgeInsets.only(
                                  right: size.width < 1004 ? 0 : 30.0),
                              child: material.Column(
                                crossAxisAlignment:
                                    material.CrossAxisAlignment.end,
                                mainAxisAlignment:
                                    material.MainAxisAlignment.center,
                                children: [
                                  material.Container(
                                    padding: const material.EdgeInsets.only(
                                        right: 20, left: 10),
                                    height: 20,
                                    width: (size.width > 860) ? 220 : 180,
                                    child: Obx(() {
                                      final volume =
                                          playerController.volume.value;
                                      return material.Row(
                                        children: [
                                          material.SizedBox(
                                              width: 20,
                                              child: material.InkWell(
                                                onTap: playerController.mute,
                                                child: material.Icon(
                                                  volume == 0
                                                      ? material
                                                          .Icons.volume_off
                                                      : volume > 0 &&
                                                              volume < 50
                                                          ? material
                                                              .Icons.volume_down
                                                          : material
                                                              .Icons.volume_up,
                                                  size: 20,
                                                ),
                                              )),
                                          material.Expanded(
                                            child: material.SliderTheme(
                                              data: material.SliderTheme.of(
                                                      context)
                                                  .copyWith(
                                                trackHeight: 2,
                                                thumbShape: const material
                                                    .RoundSliderThumbShape(
                                                    enabledThumbRadius: 6.0),
                                                overlayShape: const material
                                                    .RoundSliderOverlayShape(
                                                    overlayRadius: 10.0),
                                              ),
                                              child: material.Slider(
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
                                  material.SizedBox(
                                    height: 40,
                                    child: material.Row(
                                      mainAxisAlignment:
                                          material.MainAxisAlignment.end,
                                      children: [
                                        material.IconButton(
                                          onPressed: () {
                                            playerController
                                                .homeScaffoldkey.currentState!
                                                .openEndDrawer();
                                          },
                                          icon: const material.Icon(
                                              material.Icons.queue_music),
                                        ),
                                        if (size.width > 860)
                                          material.Padding(
                                            padding:
                                                const material.EdgeInsets.only(
                                                    left: 10.0),
                                            child: material.IconButton(
                                              onPressed: () {
                                                material.showModalBottomSheet(
                                                  constraints: const material
                                                      .BoxConstraints(
                                                      maxWidth: 500),
                                                  shape: const material
                                                      .RoundedRectangleBorder(
                                                    borderRadius: material
                                                            .BorderRadius
                                                        .vertical(
                                                            top: material.Radius
                                                                .circular(
                                                                    10.0)),
                                                  ),
                                                  isScrollControlled: true,
                                                  context: playerController
                                                      .homeScaffoldkey
                                                      .currentState!
                                                      .context,
                                                  barrierColor: material
                                                      .Colors.transparent
                                                      .withAlpha(100),
                                                  builder: (context) =>
                                                      const SleepTimerBottomSheet(),
                                                );
                                              },
                                              icon: material.Icon(
                                                  playerController
                                                          .isSleepTimerActive
                                                          .isTrue
                                                      ? material.Icons.timer
                                                      : material.Icons
                                                          .timer_outlined),
                                            ),
                                          ),
                                        const material.SizedBox(
                                          width: 10,
                                        ),
                                        const SongDownloadButton(
                                          calledFromPlayer: true,
                                        ),
                                        const material.SizedBox(
                                          width: 10,
                                        ),
                                        material.IconButton(
                                          onPressed: () {
                                            final currentSong = playerController
                                                .currentSong.value;
                                            if (currentSong != null) {
                                              material
                                                  .showDialog(
                                                    context: context,
                                                    builder: (context) =>
                                                        AddToPlaylist(
                                                            [currentSong]),
                                                  )
                                                  .whenComplete(() => Get.delete<
                                                      AddToPlaylistController>());
                                            }
                                          },
                                          icon: const material.Icon(
                                              material.Icons.playlist_add),
                                        ),
                                        if (size.width > 965)
                                          material.IconButton(
                                            onPressed: () {
                                              final currentSong =
                                                  playerController
                                                      .currentSong.value;
                                              if (currentSong != null) {
                                                material.showDialog(
                                                  context: context,
                                                  builder: (context) =>
                                                      SongInfoDialog(
                                                    song: currentSong,
                                                  ),
                                                );
                                              }
                                            },
                                            icon: const material.Icon(
                                                material.Icons.info,
                                                size: 22),
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
