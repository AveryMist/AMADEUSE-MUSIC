import 'package:flutter/material.dart';
import 'package:flutter_lyric/lyrics_reader.dart';
import 'package:get/get.dart';

import '../../widgets/loader.dart';
import '../player_controller.dart';

class LyricsWidget extends StatelessWidget {
  final EdgeInsetsGeometry padding;
  const LyricsWidget({super.key, required this.padding});

  @override
  Widget build(BuildContext context) {
    final playerController = Get.find<PlayerController>();
    final isMobile = GetPlatform.isMobile;

    return Obx(
      () => playerController.isLyricsLoading.isTrue
          ? const Center(
              child: LoadingIndicator(),
            )
          : playerController.lyricsMode.toInt() == 1
              ? _buildPlainLyrics(context, playerController, isMobile)
              : _buildSyncedLyrics(context, playerController, isMobile),
    );
  }

  Widget _buildPlainLyrics(BuildContext context, PlayerController playerController, bool isMobile) {
    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: padding,
        child: Obx(
          () => Container(
            decoration: isMobile ? BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.2),
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.2),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
              // Add subtle border for better definition
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
                width: 1,
              ),
              // Add shadow for depth
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ) : BoxDecoration(
              // Enhanced styling for desktop
              borderRadius: BorderRadius.circular(12),
              color: playerController.isDesktopLyricsDialogOpen
                  ? Colors.transparent
                  : Colors.black.withValues(alpha: 0.1),
              border: playerController.isDesktopLyricsDialogOpen
                  ? null
                  : Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                      width: 1,
                    ),
            ),
            padding: isMobile
                ? const EdgeInsets.symmetric(horizontal: 20, vertical: 16)
                : const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: TextSelectionTheme(
              data: Theme.of(context).textSelectionTheme,
              child: SelectableText(
                playerController.lyrics["plainLyrics"] == "NA"
                    ? "lyricsNotAvailable".tr
                    : _formatPlainLyrics(playerController.lyrics["plainLyrics"]),
                textAlign: TextAlign.center,
                style: _getPlainLyricsTextStyle(context, playerController, isMobile),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSyncedLyrics(BuildContext context, PlayerController playerController, bool isMobile) {
    return Obx(() => IgnorePointer(
      child: Container(
        decoration: isMobile ? BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: 0.2),
              Colors.transparent,
              Colors.black.withValues(alpha: 0.2),
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
          // Add subtle border for better definition
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
          // Add shadow for depth
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ) : BoxDecoration(
          // Enhanced styling for desktop
          borderRadius: BorderRadius.circular(12),
          color: playerController.isDesktopLyricsDialogOpen
              ? Colors.transparent
              : Colors.black.withValues(alpha: 0.1),
          border: playerController.isDesktopLyricsDialogOpen
              ? null
              : Border.all(
                  color: Colors.white.withValues(alpha: 0.1),
                  width: 1,
                ),
        ),
        child: LyricsReader(
          padding: isMobile
              ? const EdgeInsets.symmetric(horizontal: 20, vertical: 12)
              : const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          lyricUi: _getSyncedLyricsUI(playerController, isMobile),
          position: playerController.progressBarStatus.value.current.inMilliseconds,
          model: LyricsModelBuilder.create()
              .bindLyricToMain(playerController.lyrics['synced'].toString())
              .getModel(),
          emptyBuilder: () => Center(
            child: Container(
              padding: isMobile ? const EdgeInsets.all(20) : const EdgeInsets.all(16),
              decoration: isMobile ? BoxDecoration(
                color: Colors.black.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 1,
                ),
              ) : BoxDecoration(
                color: playerController.isDesktopLyricsDialogOpen
                    ? Theme.of(context).cardColor.withValues(alpha: 0.5)
                    : Colors.black.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "syncedLyricsNotAvailable".tr,
                style: _getSyncedLyricsEmptyTextStyle(context, playerController, isMobile),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    ));
  }

  String _formatPlainLyrics(String lyrics) {
    if (lyrics.isEmpty) return lyrics;

    // Split by lines and clean up
    final lines = lyrics.split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    // Group lines into verses for better structure
    final List<String> verses = [];
    List<String> currentVerse = [];

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];

      // Check if this might be a section marker (chorus, verse, etc.)
      if (line.toLowerCase().contains('chorus') ||
          line.toLowerCase().contains('verse') ||
          line.toLowerCase().contains('bridge') ||
          line.toLowerCase().contains('outro') ||
          line.toLowerCase().contains('intro') ||
          line.startsWith('[') && line.endsWith(']')) {
        // Add previous verse if exists
        if (currentVerse.isNotEmpty) {
          verses.add(currentVerse.join('\n'));
          currentVerse = [];
        }
        // Add section marker with emphasis
        verses.add('• ${line.replaceAll('[', '').replaceAll(']', '')} •');
      } else {
        currentVerse.add(line);

        // Create verse breaks every 4-6 lines for better readability
        if (currentVerse.length >= 4 && i < lines.length - 1) {
          // Check if next line might start a new section
          final nextLine = i + 1 < lines.length ? lines[i + 1] : '';
          if (nextLine.isEmpty ||
              nextLine.toLowerCase().contains('chorus') ||
              nextLine.toLowerCase().contains('verse') ||
              currentVerse.length >= 6) {
            verses.add(currentVerse.join('\n'));
            currentVerse = [];
          }
        }
      }
    }

    // Add remaining verse
    if (currentVerse.isNotEmpty) {
      verses.add(currentVerse.join('\n'));
    }

    // Join verses with double spacing for better readability
    return verses.join('\n\n');
  }

  TextStyle _getPlainLyricsTextStyle(BuildContext context, PlayerController playerController, bool isMobile) {
    final baseStyle = playerController.isDesktopLyricsDialogOpen
        ? Theme.of(context).textTheme.titleMedium!
        : Theme.of(context).textTheme.titleMedium!.copyWith(color: Colors.white);

    if (isMobile) {
      return baseStyle.copyWith(
        fontSize: 18,
        height: 1.8, // Better line spacing for readability
        fontWeight: FontWeight.w500,
        letterSpacing: 0.8,
        shadows: [
          Shadow(
            offset: const Offset(1, 1),
            blurRadius: 4,
            color: Colors.black.withValues(alpha: 0.8),
          ),
          // Add a subtle glow effect
          Shadow(
            offset: const Offset(0, 0),
            blurRadius: 8,
            color: Colors.white.withValues(alpha: 0.1),
          ),
        ],
      );
    }

    // Enhanced desktop styling
    return baseStyle.copyWith(
      fontSize: playerController.isDesktopLyricsDialogOpen ? 18 : 20,
      height: 1.7,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.6,
      shadows: playerController.isDesktopLyricsDialogOpen
          ? null
          : [
              Shadow(
                offset: const Offset(1, 1),
                blurRadius: 3,
                color: Colors.black.withValues(alpha: 0.6),
              ),
            ],
    );
  }

  UINetease _getSyncedLyricsUI(PlayerController playerController, bool isMobile) {
    if (isMobile) {
      return UINetease(
        highlight: true,
        defaultSize: 20,
        defaultExtSize: 16,
      );
    }

    return UINetease(
      highlight: true,
      defaultSize: GetPlatform.isDesktop ? 24 : 22,
      defaultExtSize: GetPlatform.isDesktop ? 18 : 14,
    );
  }

  TextStyle _getSyncedLyricsEmptyTextStyle(BuildContext context, PlayerController playerController, bool isMobile) {
    final baseStyle = playerController.isDesktopLyricsDialogOpen
        ? Theme.of(context).textTheme.titleMedium!
        : Theme.of(context).textTheme.titleMedium!.copyWith(color: Colors.white);

    if (isMobile) {
      return baseStyle.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
        shadows: [
          Shadow(
            offset: const Offset(1, 1),
            blurRadius: 3,
            color: Colors.black.withValues(alpha: 0.7),
          ),
        ],
      );
    }

    return baseStyle;
  }
}
