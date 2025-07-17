import 'package:flutter/material.dart' as material;
import 'package:get/get.dart';
import 'package:harmonymusic/ui/utils/theme_controller.dart';
import 'package:toggle_switch/toggle_switch.dart';

import '../player_controller.dart';

class LyricsSwitch extends material.StatelessWidget {
  const LyricsSwitch({super.key});

  @override
  material.Widget build(material.BuildContext context) {
    final PlayerController playerController = Get.find<PlayerController>();
    return Obx(
      () => playerController.showLyricsflag.value
          ? material.Padding(
              padding: const material.EdgeInsets.only(bottom: 10.0),
              child: ToggleSwitch(
                minWidth: 90.0,
                cornerRadius: 20.0,
                activeBgColors: [
                  [material.Theme.of(context).primaryColor.withLightness(0.4)],
                  [material.Theme.of(context).primaryColor.withLightness(0.4)]
                ],
                activeFgColor: material.Colors.white,
                inactiveBgColor: material.Theme.of(context).colorScheme.secondary,
                inactiveFgColor: material.Colors.white,
                initialLabelIndex: playerController.lyricsMode.value,
                totalSwitches: 2,
                labels: ['synced'.tr, 'plain'.tr],
                radiusStyle: true,
                onToggle: playerController.changeLyricsMode,
              ),
            )
          : const material.SizedBox.shrink(),
    );
  }
}
