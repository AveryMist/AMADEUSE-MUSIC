import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:widget_marquee/widget_marquee.dart';

import '/ui/player/components/animated_play_button.dart';
import '/ui/themes/modern_button_theme.dart';
import '../player_controller.dart';

class PlayerControlWidget extends StatelessWidget {
  const PlayerControlWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final PlayerController playerController = Get.find<PlayerController>();
    return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: ShaderMask(
                  shaderCallback: (rect) {
                    return const LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Colors.white,
                        Colors.white,
                        Colors.white,
                        Colors.white,
                        Colors.white,
                        Colors.white,
                        Colors.transparent
                      ],
                    ).createShader(
                        Rect.fromLTWH(0, 0, rect.width, rect.height));
                  },
                  blendMode: BlendMode.dstIn,
                  child: Obx(() {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Marquee(
                          delay: const Duration(milliseconds: 300),
                          duration: const Duration(seconds: 10),
                          id: "${playerController.currentSong.value}_title",
                          child: Text(
                            playerController.currentSong.value != null
                                ? playerController.currentSong.value!.title
                                : "NA",
                            textAlign: TextAlign.start,
                            style: Theme.of(context).textTheme.labelMedium!,
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Marquee(
                          delay: const Duration(milliseconds: 300),
                          duration: const Duration(seconds: 10),
                          id: "${playerController.currentSong.value}_subtitle",
                          child: GestureDetector(
                            onTap: () {
                              // Naviguer vers le profil de l'artiste
                              if (playerController.currentSong.value != null &&
                                  playerController.currentSong.value!.extras != null &&
                                  playerController.currentSong.value!.extras!['artists'] != null) {
                                final artists = playerController.currentSong.value!.extras!['artists'];
                                if (artists.isNotEmpty && artists[0]['id'] != null) {
                                  // Fermer/minimiser le panneau du player avant navigation
                                  playerController.playerPanelController.close();
                                  Get.toNamed('/artistScreen',
                                      id: 1,
                                      arguments: [true, artists[0]['id']]);
                                }
                              }
                            },
                            child: Text(
                              playerController.currentSong.value != null
                                  ? playerController.currentSong.value!.artist!
                                  : "NA",
                              textAlign: TextAlign.start,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.labelSmall!.copyWith(
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                                color: Colors.lightBlue,
                                decorationColor: Colors.lightBlue,
                              ),
                            ),
                          ),
                        )
                      ],
                    );
                  }),
                ),
              ),
              SizedBox(
                width: 45,
                child: Obx(() => ModernButtonTheme.modernIconButton(
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
                  size: 20,
                )),
              ),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          GetX<PlayerController>(builder: (controller) {
            return ProgressBar(
              thumbRadius: 7,
              barHeight: 4.5,
              baseBarColor: Theme.of(context).sliderTheme.inactiveTrackColor,
              bufferedBarColor:
                  Theme.of(context).sliderTheme.valueIndicatorColor,
              progressBarColor: Theme.of(context).sliderTheme.activeTrackColor,
              thumbColor: Theme.of(context).sliderTheme.thumbColor,
              timeLabelTextStyle: Theme.of(context)
                  .textTheme
                  .titleMedium!
                  .copyWith(fontSize: 14),
              progress: controller.progressBarStatus.value.current,
              total: controller.progressBarStatus.value.total,
              buffered: controller.progressBarStatus.value.buffered,
              onSeek: controller.seek,
            );
          }),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Obx(() => ModernButtonTheme.modernIconButton(
                icon: Ionicons.shuffle,
                onPressed: playerController.toggleShuffleMode,
                context: context,
                color: playerController.isShuffleModeEnabled.value
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).textTheme.titleLarge!.color!.withValues(alpha: 0.6),
                isSelected: playerController.isShuffleModeEnabled.value,
                tooltip: 'Lecture aléatoire',
                size: 28,
              )),
              _previousButton(playerController, context),
              ModernButtonTheme.modernPlayButton(
                child: const AnimatedPlayButton(key: Key("playButton")),
                onPressed: null,
                context: context,
                size: 70,
              ),
              _nextButton(playerController, context),
              Obx(() => ModernButtonTheme.modernIconButton(
                icon: Icons.all_inclusive,
                onPressed: playerController.toggleLoopMode,
                context: context,
                color: playerController.isLoopModeEnabled.value
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).textTheme.titleLarge!.color!.withValues(alpha: 0.6),
                isSelected: playerController.isLoopModeEnabled.value,
                tooltip: 'Répétition',
                size: 28,
              )),
            ],
          ),
        ]);
  }


  Widget _previousButton(
      PlayerController playerController, BuildContext context) {
    return ModernButtonTheme.modernIconButton(
      icon: Icons.skip_previous,
      onPressed: playerController.prev,
      context: context,
      color: Theme.of(context).textTheme.titleMedium!.color,
      tooltip: 'Précédent',
      size: 30,
    );
  }
}

Widget _nextButton(PlayerController playerController, BuildContext context) {
  return Obx(() {
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
          ? Theme.of(context).textTheme.titleLarge!.color!.withValues(alpha: 0.3)
          : Theme.of(context).textTheme.titleMedium!.color,
      tooltip: 'Suivant',
      size: 30,
    );
  });
}
