import 'package:get/get.dart';
import 'package:flutter/material.dart';

class HelpController extends GetxController {
  final searchController = TextEditingController();
  final searchQuery = ''.obs;
  final selectedCategory = ''.obs;
  final expandedSections = <String>{}.obs;
  
  // Help categories
  final List<HelpCategory> helpCategories = [
    HelpCategory(
      id: 'getting_started',
      titleKey: 'helpGettingStarted',
      iconData: Icons.play_circle_outline,
      sections: [
        HelpSection(
          id: 'first_launch',
          titleKey: 'helpFirstLaunch',
          contentKey: 'helpFirstLaunchContent',
        ),
        HelpSection(
          id: 'interface_overview',
          titleKey: 'helpInterfaceOverview',
          contentKey: 'helpInterfaceOverviewContent',
        ),
        HelpSection(
          id: 'basic_navigation',
          titleKey: 'helpBasicNavigation',
          contentKey: 'helpBasicNavigationContent',
        ),
      ],
    ),
    HelpCategory(
      id: 'music_playback',
      titleKey: 'helpMusicPlayback',
      iconData: Icons.music_note,
      sections: [
        HelpSection(
          id: 'playing_music',
          titleKey: 'helpPlayingMusic',
          contentKey: 'helpPlayingMusicContent',
        ),
        HelpSection(
          id: 'player_controls',
          titleKey: 'helpPlayerControls',
          contentKey: 'helpPlayerControlsContent',
        ),
        HelpSection(
          id: 'queue_management',
          titleKey: 'helpQueueManagement',
          contentKey: 'helpQueueManagementContent',
        ),
        HelpSection(
          id: 'player_modes',
          titleKey: 'helpPlayerModes',
          contentKey: 'helpPlayerModesContent',
        ),
      ],
    ),
    HelpCategory(
      id: 'lyrics',
      titleKey: 'helpLyrics',
      iconData: Icons.lyrics,
      sections: [
        HelpSection(
          id: 'viewing_lyrics',
          titleKey: 'helpViewingLyrics',
          contentKey: 'helpViewingLyricsContent',
        ),
        HelpSection(
          id: 'synced_lyrics',
          titleKey: 'helpSyncedLyrics',
          contentKey: 'helpSyncedLyricsContent',
        ),
        HelpSection(
          id: 'plain_lyrics',
          titleKey: 'helpPlainLyrics',
          contentKey: 'helpPlainLyricsContent',
        ),
      ],
    ),
    HelpCategory(
      id: 'library',
      titleKey: 'helpLibrary',
      iconData: Icons.library_music,
      sections: [
        HelpSection(
          id: 'managing_playlists',
          titleKey: 'helpManagingPlaylists',
          contentKey: 'helpManagingPlaylistsContent',
        ),
        HelpSection(
          id: 'favorites',
          titleKey: 'helpFavorites',
          contentKey: 'helpFavoritesContent',
        ),
        HelpSection(
          id: 'downloads',
          titleKey: 'helpDownloads',
          contentKey: 'helpDownloadsContent',
        ),
      ],
    ),
    HelpCategory(
      id: 'search',
      titleKey: 'helpSearch',
      iconData: Icons.search,
      sections: [
        HelpSection(
          id: 'searching_music',
          titleKey: 'helpSearchingMusic',
          contentKey: 'helpSearchingMusicContent',
        ),
        HelpSection(
          id: 'search_filters',
          titleKey: 'helpSearchFilters',
          contentKey: 'helpSearchFiltersContent',
        ),
      ],
    ),
    HelpCategory(
      id: 'settings',
      titleKey: 'helpSettings',
      iconData: Icons.settings,
      sections: [
        HelpSection(
          id: 'audio_settings',
          titleKey: 'helpAudioSettings',
          contentKey: 'helpAudioSettingsContent',
        ),
        HelpSection(
          id: 'theme_settings',
          titleKey: 'helpThemeSettings',
          contentKey: 'helpThemeSettingsContent',
        ),
        HelpSection(
          id: 'language_settings',
          titleKey: 'helpLanguageSettings',
          contentKey: 'helpLanguageSettingsContent',
        ),
        HelpSection(
          id: 'player_ui_settings',
          titleKey: 'helpPlayerUISettings',
          contentKey: 'helpPlayerUISettingsContent',
        ),
      ],
    ),
    HelpCategory(
      id: 'troubleshooting',
      titleKey: 'helpTroubleshooting',
      iconData: Icons.help_outline,
      sections: [
        HelpSection(
          id: 'common_issues',
          titleKey: 'helpCommonIssues',
          contentKey: 'helpCommonIssuesContent',
        ),
        HelpSection(
          id: 'performance_tips',
          titleKey: 'helpPerformanceTips',
          contentKey: 'helpPerformanceTipsContent',
        ),
        HelpSection(
          id: 'reset_settings',
          titleKey: 'helpResetSettings',
          contentKey: 'helpResetSettingsContent',
        ),
      ],
    ),
  ];

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(_onSearchChanged);
  }

  @override
  void onClose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.onClose();
  }

  void _onSearchChanged() {
    searchQuery.value = searchController.text;
  }

  void selectCategory(String categoryId) {
    selectedCategory.value = categoryId;
  }

  void toggleSection(String sectionId) {
    if (expandedSections.contains(sectionId)) {
      expandedSections.remove(sectionId);
    } else {
      expandedSections.add(sectionId);
    }
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
  }

  List<HelpSection> getFilteredSections() {
    if (searchQuery.value.isEmpty) {
      return [];
    }

    List<HelpSection> filteredSections = [];
    String query = searchQuery.value.toLowerCase();

    for (var category in helpCategories) {
      for (var section in category.sections) {
        String title = section.titleKey.tr.toLowerCase();
        String content = section.contentKey.tr.toLowerCase();
        
        if (title.contains(query) || content.contains(query)) {
          filteredSections.add(section);
        }
      }
    }

    return filteredSections;
  }

  HelpCategory? getCategoryById(String categoryId) {
    try {
      return helpCategories.firstWhere((category) => category.id == categoryId);
    } catch (e) {
      return null;
    }
  }
}

class HelpCategory {
  final String id;
  final String titleKey;
  final IconData iconData;
  final List<HelpSection> sections;

  HelpCategory({
    required this.id,
    required this.titleKey,
    required this.iconData,
    required this.sections,
  });
}

class HelpSection {
  final String id;
  final String titleKey;
  final String contentKey;

  HelpSection({
    required this.id,
    required this.titleKey,
    required this.contentKey,
  });
}
