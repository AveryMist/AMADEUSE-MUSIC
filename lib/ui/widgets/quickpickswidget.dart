import 'package:flutter/gestures.dart' show kSecondaryMouseButton;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '/models/quick_picks.dart';
import '../player/player_controller.dart';
import 'image_widget.dart';
import 'songinfo_bottom_sheet.dart';

class QuickPicksWidget extends StatelessWidget {
  const QuickPicksWidget(
      {super.key, required this.content, this.scrollController});
  final QuickPicks content;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    final PlayerController playerController = Get.find<PlayerController>();
    final isDesktop = GetPlatform.isDesktop;

    return Container(
      height: isDesktop ? 380 : 340,  // Increased height for desktop
      width: double.infinity,
      margin: isDesktop ? const EdgeInsets.symmetric(horizontal: 20, vertical: 10) : null,
      decoration: isDesktop ? BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.7),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ) : null,
      child: Padding(
        padding: isDesktop ? const EdgeInsets.all(20) : EdgeInsets.zero,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              children: [
                if (isDesktop)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.music_note,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                  ),
                if (isDesktop) const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    content.title.tr,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: isDesktop ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: isDesktop ? 16 : 10),
          Expanded(
            child: Scrollbar(
              thickness: GetPlatform.isDesktop ? null : 0,
              controller: scrollController,
              child: GridView.builder(
                  controller: scrollController,
                  physics: const BouncingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  itemCount: content.songList.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    childAspectRatio: .26 / 1,
                    crossAxisSpacing: 1,
                    mainAxisSpacing: 5,
                  ),
                  itemBuilder: (_, item) {
                    return Listener(
                      onPointerDown: (PointerDownEvent event) {
                        if (event.buttons == kSecondaryMouseButton) {
                          //show songinfobotomsheet
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
                            builder: (context) => SongInfoBottomSheet(
                              content.songList[item],
                            ),
                          ).whenComplete(
                              () => Get.delete<SongInfoController>());
                        }
                      },
                      child: ListTile(
                          contentPadding: const EdgeInsets.only(left: 5),
                          leading: ImageWidget(
                            song: content.songList[item],
                            size: 55,
                          ),
                          title: Text(
                            content.songList[item].title,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          subtitle: Text(
                            "${content.songList[item].artist}",
                            maxLines: 1,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          onTap: () {
                            playerController
                                .pushSongToQueue(content.songList[item]);
                          },
                          onLongPress: () {
                            showModalBottomSheet(
                              constraints: const BoxConstraints(maxWidth: 500),
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(10.0)),
                              ),
                              isScrollControlled: true,
                              context: playerController
                                  .homeScaffoldkey.currentState!.context,
                              //constraints: BoxConstraints(maxHeight:Get.height),
                              barrierColor: Colors.transparent.withAlpha(100),
                              builder: (context) =>
                                  SongInfoBottomSheet(content.songList[item]),
                            ).whenComplete(
                                () => Get.delete<SongInfoController>());
                          },
                          trailing: (GetPlatform.isDesktop)
                              ? IconButton(
                                  splashRadius: 20,
                                  onPressed: () {
                                    showModalBottomSheet(
                                      constraints:
                                          const BoxConstraints(maxWidth: 500),
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(10.0)),
                                      ),
                                      isScrollControlled: true,
                                      context: playerController.homeScaffoldkey
                                          .currentState!.context,
                                      //constraints: BoxConstraints(maxHeight:Get.height),
                                      barrierColor:
                                          Colors.transparent.withAlpha(100),
                                      builder: (context) => SongInfoBottomSheet(
                                          content.songList[item]),
                                    ).whenComplete(
                                        () => Get.delete<SongInfoController>());
                                  },
                                  icon: const Icon(Icons.more_vert))
                              : null),
                    );
                  }),
            ),
          ),
          const SizedBox(height: 20)
        ],
      ),
    ),
    );
  }
}
