import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';
import 'dart:io';

import '../screens/Home/home_screen_controller.dart';
import 'common_dialog_widget.dart';
import 'snackbar.dart';

class NewVersionDialog extends StatelessWidget {
  const NewVersionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonDialog(
      child: Container(
        height: 320,
        padding: const EdgeInsets.only(top: 40, bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "newVersionAvailable".tr,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Icon(
                  Icons.info_outline,
                  size: 80,
                ),
            ),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GetX<HomeScreenController>(builder: (controller) {
                    return Checkbox(
                        value: controller.showVersionDialog.isFalse,
                        onChanged: (val) {
                          controller.onChangeVersionVisibility(val ?? false);
                        },
                        shape: const CircleBorder());
                  }),
                  Text("dontShowInfoAgain".tr)
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                    decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(10)),
                    child: InkWell(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15.0, vertical: 10),
                        child: Text("download".tr,
                            style: TextStyle(color: Theme.of(context).canvasColor)),
                      ),
                      onTap: () async {
                         Navigator.of(context).pop();
                         await _downloadAndInstallUpdate();
                       },
                    )),
                Container(
                    decoration: BoxDecoration(
                        color: Theme.of(context).textTheme.titleLarge!.color,
                        borderRadius: BorderRadius.circular(10)),
                    child: InkWell(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15.0, vertical: 10),
                        child: Text("dismiss".tr,
                            style: TextStyle(color: Theme.of(context).canvasColor)),
                      ),
                      onTap: () => Navigator.of(context).pop(),
                    ))
              ],
            )
          ],
        ),
      ),
    );
  }

  Future<void> _downloadAndInstallUpdate() async {
    try {
      // Demander les permissions de stockage
      if (await Permission.storage.request().isGranted ||
          await Permission.manageExternalStorage.request().isGranted) {
        
        // Afficher un message de début de téléchargement
         ScaffoldMessenger.of(Get.context!).showSnackBar(
           snackbar(Get.context!, "Téléchargement de la mise à jour en cours...")
         );
        
        // Obtenir la dernière version depuis GitHub API
        final dio = Dio();
        final response = await dio.get(
          "https://api.github.com/repos/AveryMist/AMADEUSE-MUSIC/releases/latest"
        );
        
        final latestRelease = response.data;
        final downloadUrl = latestRelease['assets']
            .firstWhere((asset) => asset['name'].endsWith('.apk'))['browser_download_url'];
        
        // Obtenir le répertoire de téléchargement
        final directory = await getExternalStorageDirectory();
        final downloadPath = '${directory!.path}/amadeuse_update.apk';
        
        // Télécharger le fichier APK
        await dio.download(
          downloadUrl,
          downloadPath,
          onReceiveProgress: (received, total) {
            if (total != -1) {
               final progress = (received / total * 100).toStringAsFixed(0);
               ScaffoldMessenger.of(Get.context!).showSnackBar(
                 snackbar(Get.context!, "Téléchargement: $progress%")
               );
             }
          },
        );
        
        ScaffoldMessenger.of(Get.context!).showSnackBar(
           snackbar(Get.context!, "Téléchargement terminé! Installation en cours...")
         );
         
         // Installer l'APK
         await OpenFile.open(downloadPath);
         
       } else {
         ScaffoldMessenger.of(Get.context!).showSnackBar(
           snackbar(Get.context!, "Permission de stockage requise pour télécharger la mise à jour")
         );
       }
     } catch (e) {
       ScaffoldMessenger.of(Get.context!).showSnackBar(
         snackbar(Get.context!, "Erreur lors du téléchargement: $e")
       );
    }
  }
}
