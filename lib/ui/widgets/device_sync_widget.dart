import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:amadeusemusic/utils/helper.dart';

import '../../services/device_sync_service.dart';
import 'snackbar.dart';

class DeviceSyncWidget extends StatelessWidget {
  const DeviceSyncWidget({
    super.key,
    required this.padding,
    this.iconSize = 20,
    this.splashRadius = 20,
  });

  final EdgeInsets padding;
  final double iconSize;
  final double splashRadius;

  @override
  Widget build(BuildContext context) {
    // Check if DeviceSyncService is registered
    if (!Get.isRegistered<DeviceSyncService>()) {
      return Padding(
        padding: padding,
        child: IconButton(
          splashRadius: splashRadius,
          iconSize: iconSize,
          visualDensity: const VisualDensity(vertical: -4),
          icon: const Icon(
            Icons.sync,
            color: Colors.grey,
          ),
          tooltip: "Service de synchronisation non disponible",
          onPressed: () {
            ScaffoldMessenger.of(Get.context!).showSnackBar(snackbar(
                Get.context!, "Activez la synchronisation dans les paramètres",
                size: SanckBarSize.MEDIUM));
          },
        ),
      );
    }

    final syncService = Get.find<DeviceSyncService>();
    return Padding(
      padding: padding,
      child: Obx(() {
        final isSyncing = syncService.isSyncing.value;
        final isConnected = syncService.connectedDevices.isNotEmpty;

        return AnimatedRotation(
          turns: isSyncing ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 1000),
          child: IconButton(
            splashRadius: splashRadius,
            iconSize: iconSize,
            visualDensity: const VisualDensity(vertical: -4),
            icon: Icon(
              Icons.sync,
              color: isConnected
                  ? (isSyncing
                      ? Colors.blue
                      : Theme.of(context).iconTheme.color)
                  : Colors.grey,
            ),
            tooltip: isConnected
                ? (isSyncing
                    ? "Synchronisation en cours..."
                    : "Synchroniser les appareils appairés")
                : "Aucun appareil connecté",
            onPressed: isSyncing
                ? null
                : () async {
                    if (!isConnected) {
                      ScaffoldMessenger.of(Get.context!).showSnackBar(snackbar(
                          Get.context!, "Aucun appareil appairé connecté",
                          size: SanckBarSize.MEDIUM));
                      return;
                    }

                    try {
                      printINFO("Manual sync triggered by user");

                      // Show loading dialog
                      showDialog(
                        context: Get.context!,
                        barrierDismissible: false,
                        builder: (context) => const DeviceSyncLoadingDialog(),
                      );

                      final success = await syncService.performManualSync();

                      // Close loading dialog
                      Navigator.of(Get.context!).pop();

                      if (success) {
                        ScaffoldMessenger.of(Get.context!).showSnackBar(
                            snackbar(Get.context!,
                                "Synchronisation terminée avec succès",
                                size: SanckBarSize.MEDIUM));
                      } else {
                        ScaffoldMessenger.of(Get.context!).showSnackBar(snackbar(
                            Get.context!,
                            "Échec de la synchronisation: ${syncService.syncStatus.value}",
                            size: SanckBarSize.MEDIUM));
                      }
                    } catch (e) {
                      // Close loading dialog if still open
                      if (Navigator.of(Get.context!).canPop()) {
                        Navigator.of(Get.context!).pop();
                      }

                      printERROR("Error during manual sync: $e");
                      ScaffoldMessenger.of(Get.context!).showSnackBar(snackbar(
                          Get.context!, "Erreur lors de la synchronisation: $e",
                          size: SanckBarSize.MEDIUM));
                    }
                  },
          ),
        );
      }),
    );
  }
}

class DeviceSyncLoadingDialog extends StatelessWidget {
  const DeviceSyncLoadingDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final syncService = Get.find<DeviceSyncService>();
    return AlertDialog(
      backgroundColor: Theme.of(context).dialogTheme.backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      content: Obx(() {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 50,
              height: 50,
              child: CircularProgressIndicator(
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Synchronisation des appareils appairés",
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              syncService.syncStatus.value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 15),
            Text(
              "Appareils connectés: ${syncService.connectedDevices.length}",
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[500],
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        );
      }),
    );
  }
}
