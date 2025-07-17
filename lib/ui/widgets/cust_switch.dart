import 'package:flutter/material.dart' as material;
import 'package:get/get.dart';
import 'package:harmonymusic/ui/utils/theme_controller.dart';

class CustSwitch extends material.StatelessWidget {
  const CustSwitch({super.key, this.onChanged, required this.value});
  final void Function(bool)? onChanged;
  final bool value;

  @override
  material.Widget build(material.BuildContext context) {
    final isLightMode =
        Get.find<ThemeController>().themedata.value!.primaryColor == material.Colors.white;
    return material.Switch(
        activeColor: material.Colors.white,
        activeTrackColor: isLightMode ? material.Colors.grey : null,
        inactiveTrackColor: isLightMode ? material.Colors.grey : null,
        inactiveThumbColor: isLightMode ? material.Colors.grey[300] : material.Colors.white.withOpacity(0.5),
        value: value,
        onChanged: onChanged);
  }
}

// In theme_controller.dart, to fix constant error, make sure primarySwatch is handled properly
// But since editing this file, note for next
