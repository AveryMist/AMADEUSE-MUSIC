import 'dart:ui';

import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';

import 'package:flutter/material.dart' as material;
import 'package:get/get.dart';
import 'package:amadeusemusic/ui/player/components/backgroud_image.dart';
import 'package:amadeusemusic/ui/player/components/lyrics_widget.dart';
import 'package:amadeusemusic/ui/player/components/lyrics_switch.dart';
import 'package:ionicons/ionicons.dart';
import 'package:widget_marquee/widget_marquee.dart';

import '../../widgets/songinfo_bottom_sheet.dart';
import '../../utils/theme_controller.dart';
import '../player_controller.dart';

class GesturePlayer extends material.StatelessWidget {
  const GesturePlayer({super.key});

  @override
  material.Widget build(material.BuildContext context) {
    final PlayerController playerController = Get.find<PlayerController>();
    return material.Stack(
      children: [
        material.GestureDetector(
          /// Full screen Background image is acting as album art
          child: const BackgroudImage(),
          onHorizontalDragEnd: (material.DragEndDetails details) {
            if (details.primaryVelocity! < 0) {
              playerController.next();
            } else if (details.primaryVelocity! > 0) {
              playerController.prev();
            }
          },
          onDoubleTap: () {
            playerController.playPause();
          },
          onLongPress: () {
            material
                .showModalBottomSheet(
                  constraints: const material.BoxConstraints(maxWidth: 500),
                  shape: const material.RoundedRectangleBorder(
                    borderRadius: material.BorderRadius.vertical(
                        top: material.Radius.circular(10.0)),
                  ),
                  isScrollControlled: true,
                  context:
                      playerController.homeScaffoldkey.currentState!.context,
                  barrierColor: material.Colors.transparent.withAlpha(100),
                  builder: (context) => SongInfoBottomSheet(
                    playerController.currentSong.value!,
                    calledFromPlayer: true,
                  ),
                )
                .whenComplete(() => Get.delete<SongInfoController>());
          },
        ),
        material.IgnorePointer(
          child: material.Align(
            child: material.Center(
              child: Obx(
                () => material.FadeTransition(
                  opacity: playerController.gesturePlayerStateAnimation!,
                  child: playerController.gesturePlayerVisibleState.value == 2
                      ? const material.SizedBox.shrink()
                      : material.Icon(
                          playerController.gesturePlayerVisibleState.value == 1
                              ? material.Icons.play_arrow
                              : material.Icons.pause,
                          size: 180,
                          color: material.Colors.white,
                        ),
                ),
              ),
            ),
          ),
        ),
        material.Align(
          alignment: material.Alignment.bottomCenter,
          child: material.Padding(
            padding: material.EdgeInsets.only(
                bottom: Get.mediaQuery.padding.bottom != 0
                    ? Get.mediaQuery.padding.bottom + 10
                    : 20,
                left: 20,
                right: 20),
            child: material.Container(
              decoration: material.BoxDecoration(
                  color:
                      material.Theme.of(context).primaryColor.withOpacity(0.3),
                  borderRadius: material.BorderRadius.circular(10)),
              constraints: const material.BoxConstraints(maxWidth: 500),
              height: 142,
              child: material.ClipRRect(
                borderRadius: material.BorderRadius.circular(10),
                child: material.BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                  child: material.Padding(
                    padding: const material.EdgeInsets.symmetric(
                        horizontal: 15, vertical: 10),
                    child: material.Column(children: [
                      material.Row(
                        mainAxisAlignment:
                            material.MainAxisAlignment.spaceBetween,
                        children: [
                          material.Expanded(
                            child: material.Column(
                                crossAxisAlignment:
                                    material.CrossAxisAlignment.start,
                                children: [
                                  Obx(() {
                                    return Marquee(
                                      delay: const Duration(milliseconds: 300),
                                      duration: const Duration(seconds: 10),
                                      id: "${playerController.currentSong.value}_title",
                                      child: material.Text(
                                        playerController.currentSong.value !=
                                                null
                                            ? playerController
                                                .currentSong.value!.title
                                            : "NA",
                                        textAlign: material.TextAlign.start,
                                        style: material.Theme.of(context)
                                            .textTheme
                                            .titleMedium!
                                            .copyWith(
                                                color:
                                                    material.Theme.of(context)
                                                        .primaryColor
                                                        .complementaryColor),
                                      ),
                                    );
                                  }),
                                  const material.SizedBox(
                                    height: 7,
                                  ),
                                  GetX<PlayerController>(builder: (controller) {
                                    return Marquee(
                                      delay: const Duration(milliseconds: 300),
                                      duration: const Duration(seconds: 10),
                                      id: "${playerController.currentSong.value}_subtitle",
                                      child: material.Text(
                                        playerController.currentSong.value !=
                                                null
                                            ? controller
                                                .currentSong.value!.artist!
                                            : "NA",
                                        textAlign: material.TextAlign.start,
                                        overflow:
                                            material.TextOverflow.ellipsis,
                                        style: material.Theme.of(context)
                                            .textTheme
                                            .titleSmall!
                                            .copyWith(
                                                color:
                                                    material.Theme.of(context)
                                                        .primaryColor
                                                        .complementaryColor,
                                                fontWeight:
                                                    material.FontWeight.normal),
                                      ),
                                    );
                                  }),
                                ]),
                          ),
                          material.SizedBox(
                            width:
                                100, // Augmenté pour accommoder les deux boutons côte à côte
                            child: material.Column(
                              mainAxisAlignment:
                                  material.MainAxisAlignment.start,
                              crossAxisAlignment:
                                  material.CrossAxisAlignment.end,
                              children: [
                                material.Row(
                                  mainAxisAlignment:
                                      material.MainAxisAlignment.end,
                                  children: [
                                    // Lyrics button
                                    material.IconButton(
                                      iconSize: 20,
                                      splashRadius: 10,
                                      visualDensity:
                                          const material.VisualDensity(
                                              horizontal: -4, vertical: -4),
                                      onPressed: playerController.showLyrics,
                                      icon: Obx(
                                        () => material.Icon(
                                          material.Icons.lyrics_outlined,
                                          color: playerController
                                                  .showLyricsflag.value
                                              ? material.Theme.of(context)
                                                  .textTheme
                                                  .titleMedium!
                                                  .color
                                              : material.Theme.of(context)
                                                  .textTheme
                                                  .titleMedium!
                                                  .color!
                                                  .withValues(alpha: 0.4),
                                        ),
                                      ),
                                    ),
                                    // Favorite button
                                    material.IconButton(
                                        splashRadius: 10,
                                        iconSize: 20,
                                        visualDensity:
                                            const material.VisualDensity(
                                                horizontal: -4, vertical: -4),
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
                                  ],
                                ),
                                material.Column(
                                  children: [
                                    material.Row(
                                      mainAxisAlignment: material
                                          .MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Obx(() {
                                          return material.IconButton(
                                              splashRadius: 10,
                                              visualDensity:
                                                  const material.VisualDensity(
                                                      horizontal: -4,
                                                      vertical: -4),
                                              iconSize: 18,
                                              onPressed: playerController
                                                  .toggleLoopMode,
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
                                                        .withValues(alpha: 0.2),
                                              ));
                                        }),
                                        material.IconButton(
                                          iconSize: 18,
                                          splashRadius: 10,
                                          visualDensity:
                                              const material.VisualDensity(
                                                  horizontal: -4, vertical: -4),
                                          onPressed: playerController
                                              .toggleShuffleMode,
                                          icon: Obx(
                                            () => material.Icon(
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
                                                      .withValues(alpha: 0.2),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                      const material.SizedBox(
                        height: 5,
                      ),
                      GetX<PlayerController>(builder: (controller) {
                        return ProgressBar(
                          thumbRadius: 6,
                          baseBarColor: material.Theme.of(context)
                              .sliderTheme
                              .inactiveTrackColor,
                          bufferedBarColor: material.Theme.of(context)
                              .sliderTheme
                              .valueIndicatorColor,
                          progressBarColor: material.Theme.of(context)
                              .sliderTheme
                              .activeTrackColor,
                          thumbColor:
                              material.Theme.of(context).sliderTheme.thumbColor,
                          timeLabelTextStyle: material.Theme.of(context)
                              .textTheme
                              .titleSmall!
                              .copyWith(
                                  color: material.Theme.of(context)
                                      .primaryColor
                                      .complementaryColor),
                          progress: controller.progressBarStatus.value.current,
                          total: controller.progressBarStatus.value.total,
                          buffered: controller.progressBarStatus.value.buffered,
                          onSeek: controller.seek,
                        );
                      }),
                    ]),
                  ),
                ),
              ),
            ),
          ),
        ),

        // Lyrics overlay for GesturePlayer
        Obx(() => playerController.showLyricsflag.value
            ? material.GestureDetector(
                onTap: () {
                  playerController.showLyrics();
                },
                child: material.Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: material.BoxDecoration(
                    color: material.Colors.black.withValues(alpha: 0.8),
                  ),
                  child: material.Stack(
                    children: [
                      // Lyrics content with switch
                      material.Column(
                        children: [
                          // Top padding
                          material.SizedBox(
                              height: Get.mediaQuery.size.height * 0.12),
                          // Lyrics switch (Sync/Plain buttons)
                          const LyricsSwitch(),
                          // Lyrics widget
                          material.Expanded(
                            child: LyricsWidget(
                              padding: const material.EdgeInsets.symmetric(
                                  horizontal: 20),
                            ),
                          ),
                        ],
                      ),
                      // Close button
                      material.Positioned(
                        top: 50,
                        right: 20,
                        child: material.IconButton(
                          onPressed: () {
                            playerController.showLyrics();
                          },
                          icon: const material.Icon(
                            material.Icons.close,
                            color: material.Colors.white,
                            size: 30,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : const material.SizedBox.shrink()),

        // absorb pointer to prevent the next,prev gesture from being triggered when the user tries to switch app
        material.Align(
          alignment: material.Alignment.bottomCenter,
          child: material.Padding(
            padding: material.EdgeInsets.only(
                bottom: Get.mediaQuery.padding.bottom != 0
                    ? Get.mediaQuery.padding.bottom + 10
                    : 20,
                left: 20,
                right: 20),
            child: material.Container(
              decoration: material.BoxDecoration(
                  color:
                      material.Theme.of(context).primaryColor.withOpacity(0.3),
                  borderRadius: material.BorderRadius.circular(10)),
              constraints: const material.BoxConstraints(maxWidth: 500),
              height: 142,
              child: material.ClipRRect(
                borderRadius: material.BorderRadius.circular(10),
                child: material.BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                  child: material.Padding(
                    padding: const material.EdgeInsets.symmetric(
                        horizontal: 15, vertical: 10),
                    child: material.Column(children: [
                      material.Row(
                        mainAxisAlignment:
                            material.MainAxisAlignment.spaceBetween,
                        children: [
                          material.Expanded(
                            child: material.Column(
                                crossAxisAlignment:
                                    material.CrossAxisAlignment.start,
                                children: [
                                  Obx(() {
                                    return Marquee(
                                      delay: const Duration(milliseconds: 300),
                                      duration: const Duration(seconds: 10),
                                      id: "${playerController.currentSong.value}_title",
                                      child: material.Text(
                                        playerController.currentSong.value !=
                                                null
                                            ? playerController
                                                .currentSong.value!.title
                                            : "NA",
                                        textAlign: material.TextAlign.start,
                                        style: material.Theme.of(context)
                                            .textTheme
                                            .titleMedium!
                                            .copyWith(
                                                color:
                                                    material.Theme.of(context)
                                                        .primaryColor
                                                        .complementaryColor),
                                      ),
                                    );
                                  }),
                                  const material.SizedBox(
                                    height: 7,
                                  ),
                                  GetX<PlayerController>(builder: (controller) {
                                    return Marquee(
                                      delay: const Duration(milliseconds: 300),
                                      duration: const Duration(seconds: 10),
                                      id: "${playerController.currentSong.value}_subtitle",
                                      child: material.Text(
                                        playerController.currentSong.value !=
                                                null
                                            ? controller
                                                .currentSong.value!.artist!
                                            : "NA",
                                        textAlign: material.TextAlign.start,
                                        overflow:
                                            material.TextOverflow.ellipsis,
                                        style: material.Theme.of(context)
                                            .textTheme
                                            .titleSmall!
                                            .copyWith(
                                                color:
                                                    material.Theme.of(context)
                                                        .primaryColor
                                                        .complementaryColor,
                                                fontWeight:
                                                    material.FontWeight.normal),
                                      ),
                                    );
                                  }),
                                ]),
                          ),
                          material.SizedBox(
                            width:
                                100, // Augmenté pour accommoder les deux boutons côte à côte
                            child: material.Column(
                              mainAxisAlignment:
                                  material.MainAxisAlignment.start,
                              crossAxisAlignment:
                                  material.CrossAxisAlignment.end,
                              children: [
                                material.Row(
                                  mainAxisAlignment:
                                      material.MainAxisAlignment.end,
                                  children: [
                                    // Lyrics button
                                    material.IconButton(
                                      iconSize: 20,
                                      splashRadius: 10,
                                      visualDensity:
                                          const material.VisualDensity(
                                              horizontal: -4, vertical: -4),
                                      onPressed: playerController.showLyrics,
                                      icon: Obx(
                                        () => material.Icon(
                                          material.Icons.lyrics_outlined,
                                          color: playerController
                                                  .showLyricsflag.value
                                              ? material.Theme.of(context)
                                                  .textTheme
                                                  .titleMedium!
                                                  .color
                                              : material.Theme.of(context)
                                                  .textTheme
                                                  .titleMedium!
                                                  .color!
                                                  .withValues(alpha: 0.4),
                                        ),
                                      ),
                                    ),
                                    // Favorite button
                                    material.IconButton(
                                        splashRadius: 10,
                                        iconSize: 20,
                                        visualDensity:
                                            const material.VisualDensity(
                                                horizontal: -4, vertical: -4),
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
                                  ],
                                ),
                                material.Column(
                                  children: [
                                    material.Row(
                                      mainAxisAlignment: material
                                          .MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Obx(() {
                                          return material.IconButton(
                                              splashRadius: 10,
                                              visualDensity:
                                                  const material.VisualDensity(
                                                      horizontal: -4,
                                                      vertical: -4),
                                              iconSize: 18,
                                              onPressed: playerController
                                                  .toggleLoopMode,
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
                                                        .withValues(alpha: 0.2),
                                              ));
                                        }),
                                        material.IconButton(
                                          iconSize: 18,
                                          splashRadius: 10,
                                          visualDensity:
                                              const material.VisualDensity(
                                                  horizontal: -4, vertical: -4),
                                          onPressed: playerController
                                              .toggleShuffleMode,
                                          icon: Obx(
                                            () => material.Icon(
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
                                                      .withValues(alpha: 0.2),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                      const material.SizedBox(
                        height: 5,
                      ),
                      GetX<PlayerController>(builder: (controller) {
                        return ProgressBar(
                          thumbRadius: 6,
                          baseBarColor: material.Theme.of(context)
                              .sliderTheme
                              .inactiveTrackColor,
                          bufferedBarColor: material.Theme.of(context)
                              .sliderTheme
                              .valueIndicatorColor,
                          progressBarColor: material.Theme.of(context)
                              .sliderTheme
                              .activeTrackColor,
                          thumbColor:
                              material.Theme.of(context).sliderTheme.thumbColor,
                          timeLabelTextStyle: material.Theme.of(context)
                              .textTheme
                              .titleSmall!
                              .copyWith(
                                  color: material.Theme.of(context)
                                      .primaryColor
                                      .complementaryColor),
                          progress: controller.progressBarStatus.value.current,
                          total: controller.progressBarStatus.value.total,
                          buffered: controller.progressBarStatus.value.buffered,
                          onSeek: controller.seek,
                        );
                      }),
                    ]),
                  ),
                ),
              ),
            ),
          ),
        ),

        // Lyrics overlay for GesturePlayer
        Obx(() => playerController.showLyricsflag.value
            ? material.GestureDetector(
                onTap: () {
                  playerController.showLyrics();
                },
                child: material.Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: material.BoxDecoration(
                    color: material.Colors.black.withValues(alpha: 0.8),
                  ),
                  child: material.Stack(
                    children: [
                      // Lyrics content with switch
                      material.Column(
                        children: [
                          // Top padding
                          material.SizedBox(
                              height: Get.mediaQuery.size.height * 0.12),
                          // Lyrics switch (Sync/Plain buttons)
                          const LyricsSwitch(),
                          // Lyrics widget
                          material.Expanded(
                            child: LyricsWidget(
                              padding: const material.EdgeInsets.symmetric(
                                  horizontal: 20),
                            ),
                          ),
                        ],
                      ),
                      // Close button
                      material.Positioned(
                        top: 50,
                        right: 20,
                        child: material.IconButton(
                          onPressed: () {
                            playerController.showLyrics();
                          },
                          icon: const material.Icon(
                            material.Icons.close,
                            color: material.Colors.white,
                            size: 30,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : const material.SizedBox.shrink()),

        // absorb pointer to prevent the next,prev gesture from being triggered when the user tries to switch app
        material.Align(
          alignment: material.Alignment.bottomCenter,
          child: material.AbsorbPointer(
            child: material.SizedBox(
              height: Get.mediaQuery.padding.bottom + 20,
              child: material.Container(),
            ),
          ),
        )
      ],
    );
  }
}
