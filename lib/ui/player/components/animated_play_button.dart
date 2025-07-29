import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:amadeusemusic/ui/player/player_controller.dart';

import '../../widgets/loader.dart';

/// A button that animates between a play and pause icon.
///
/// It also shows a loading indicator when the audio is in a loading state.
class AnimatedPlayButton extends StatelessWidget {
  // Remove stateful and use GetBuilder
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PlayerController>();
    return Obx(() {
      final buttonState = controller.buttonState.value;
      final isPlaying = buttonState == PlayButtonState.playing;
      final isLoading = buttonState == PlayButtonState.loading;
      return FloatingActionButton(
        onPressed: () => isPlaying ? controller.pause() : controller.play(),
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Icon(
                  isPlaying ? Icons.pause : Icons.play_arrow,
                  key: ValueKey(isPlaying),
                  color: Colors.white,
                ),
              ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        elevation: 6,
        backgroundColor: Theme.of(context).colorScheme.primary,
      );
    });
  }
}
// Remove animation controller and state
