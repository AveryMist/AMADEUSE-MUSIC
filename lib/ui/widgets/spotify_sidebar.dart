import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:amadeuse_music/ui/screens/Home/home_screen_controller.dart';

class SpotifySidebar extends StatelessWidget {
  const SpotifySidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final homeScreenController = Get.find<HomeScreenController>();
    
    return Container(
      width: 240,
      height: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF121212), // Couleur de fond Spotify
        border: Border(
          right: BorderSide(
            color: Colors.grey.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Header avec logo
          Container(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1DB954), // Vert Spotify
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.music_note,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Amadeuse Music',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
          
          // Navigation principale
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                children: [
                  // Section principale
                  _buildNavigationSection([
                    _NavigationItem(
                      icon: Icons.home_rounded,
                      label: 'home'.tr,
                      index: 0,
                      isSelected: homeScreenController.tabIndex.value == 0,
                      onTap: () => homeScreenController.onSideBarTabSelected(0),
                    ),
                    _NavigationItem(
                      icon: Icons.search_rounded,
                      label: 'search'.tr,
                      index: -1, // Index spécial pour la recherche
                      isSelected: false,
                      onTap: () {
                        // Navigation vers la recherche
                        Get.toNamed('/searchScreen', id: 1);
                      },
                    ),
                  ]),
                  
                  const SizedBox(height: 24),
                  
                  // Section Bibliothèque
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.library_music_rounded,
                          color: Colors.grey,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'library'.tr,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  _buildNavigationSection([
                    _NavigationItem(
                      icon: Icons.music_note_rounded,
                      label: 'songs'.tr,
                      index: 1,
                      isSelected: homeScreenController.tabIndex.value == 1,
                      onTap: () => homeScreenController.onSideBarTabSelected(1),
                    ),
                    _NavigationItem(
                      icon: Icons.queue_music_rounded,
                      label: 'playlists'.tr,
                      index: 2,
                      isSelected: homeScreenController.tabIndex.value == 2,
                      onTap: () => homeScreenController.onSideBarTabSelected(2),
                    ),
                    _NavigationItem(
                      icon: Icons.album_rounded,
                      label: 'albums'.tr,
                      index: 3,
                      isSelected: homeScreenController.tabIndex.value == 3,
                      onTap: () => homeScreenController.onSideBarTabSelected(3),
                    ),
                    _NavigationItem(
                      icon: Icons.people_rounded,
                      label: 'artists'.tr,
                      index: 4,
                      isSelected: homeScreenController.tabIndex.value == 4,
                      onTap: () => homeScreenController.onSideBarTabSelected(4),
                    ),
                  ]),
                  
                  const Spacer(),
                  
                  // Section paramètres en bas
                  _buildNavigationSection([
                    _NavigationItem(
                      icon: Icons.settings_rounded,
                      label: 'settings'.tr,
                      index: 5,
                      isSelected: homeScreenController.tabIndex.value == 5,
                      onTap: () => homeScreenController.onSideBarTabSelected(5),
                    ),
                  ]),
                  
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildNavigationSection(List<_NavigationItem> items) {
    return Column(
      children: items.map((item) => _buildNavigationItem(item)).toList(),
    );
  }
  
  Widget _buildNavigationItem(_NavigationItem item) {
    return Obx(() {
      final homeScreenController = Get.find<HomeScreenController>();
      final isSelected = homeScreenController.tabIndex.value == item.index;
      
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 2),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: item.onTap,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected 
                    ? Colors.white.withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    item.icon,
                    color: isSelected 
                        ? const Color(0xFF1DB954) // Vert Spotify pour l'élément sélectionné
                        : Colors.grey[400],
                    size: 20,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      item.label,
                      style: TextStyle(
                        color: isSelected 
                            ? Colors.white
                            : Colors.grey[400],
                        fontSize: 14,
                        fontWeight: isSelected 
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}

class _NavigationItem {
  final IconData icon;
  final String label;
  final int index;
  final bool isSelected;
  final VoidCallback onTap;
  
  const _NavigationItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.isSelected,
    required this.onTap,
  });
}