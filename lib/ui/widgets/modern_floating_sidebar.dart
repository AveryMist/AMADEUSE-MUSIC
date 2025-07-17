import 'dart:ui';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harmonymusic/ui/screens/Home/home_screen_controller.dart';

class ModernFloatingSidebar extends StatefulWidget {
  const ModernFloatingSidebar({super.key});

  @override
  State<ModernFloatingSidebar> createState() => _ModernFloatingSidebarState();
}

class _ModernFloatingSidebarState extends State<ModernFloatingSidebar>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _itemsController;
  late Animation<double> _mainAnimation;
  late Animation<double> _itemsAnimation;
  bool _isExpanded = false;

  final List<SidebarItem> _items = [
    SidebarItem(
      icon: Icons.home_rounded,
      label: 'home'.tr,
      index: 0,
      gradient: const LinearGradient(
        colors: [Color(0xFF667eea), Color(0xFF764ba2)],
      ),
    ),
    SidebarItem(
      icon: Icons.music_note_rounded,
      label: 'songs'.tr,
      index: 1,
      gradient: const LinearGradient(
        colors: [Color(0xFFf093fb), Color(0xFFf5576c)],
      ),
    ),
    SidebarItem(
      icon: Icons.queue_music_rounded,
      label: 'playlists'.tr,
      index: 2,
      gradient: const LinearGradient(
        colors: [Color(0xFF4facfe), Color(0xFF00f2fe)],
      ),
    ),
    SidebarItem(
      icon: Icons.album_rounded,
      label: 'albums'.tr,
      index: 3,
      gradient: const LinearGradient(
        colors: [Color(0xFF43e97b), Color(0xFF38f9d7)],
      ),
    ),
    SidebarItem(
      icon: Icons.people_rounded,
      label: 'artists'.tr,
      index: 4,
      gradient: const LinearGradient(
        colors: [Color(0xFFfa709a), Color(0xFFfee140)],
      ),
    ),
    SidebarItem(
      icon: Icons.settings_rounded,
      label: 'settings'.tr,
      index: 5,
      gradient: const LinearGradient(
        colors: [Color(0xFFa8edea), Color(0xFFfed6e3)],
      ),
    ),
    SidebarItem(
      icon: Icons.help_rounded,
      label: 'help'.tr,
      index: 6,
      gradient: const LinearGradient(
        colors: [Color(0xFFffecd2), Color(0xFFfcb69f)],
      ),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _itemsController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _mainAnimation = CurvedAnimation(
      parent: _mainController,
      curve: Curves.easeInOutCubic,
    );
    _itemsAnimation = CurvedAnimation(
      parent: _itemsController,
      curve: Curves.elasticOut,
    );
  }

  @override
  void dispose() {
    _mainController.dispose();
    _itemsController.dispose();
    super.dispose();
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
    if (_isExpanded) {
      _mainController.forward();
      Future.delayed(const Duration(milliseconds: 100), () {
        _itemsController.forward();
      });
    } else {
      _itemsController.reverse();
      Future.delayed(const Duration(milliseconds: 200), () {
        _mainController.reverse();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final homeScreenController = Get.find<HomeScreenController>();
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 480;

    return Positioned(
      left: 20,
      top: isMobile ? 100 : 120,
      child: AnimatedBuilder(
        animation: _mainAnimation,
        builder: (context, child) {
          return Container(
            width: _isExpanded ? (isMobile ? 280 : 320) : 70,
            height: _isExpanded ? (isMobile ? 420 : 480) : 70,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(35),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  blurRadius: 30,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(35),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).cardColor.withOpacity(0.2),
                        Theme.of(context).cardColor.withOpacity(0.1),
                      ],
                    ),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1.5,
                    ),
                  ),
                  child: _isExpanded ? _buildExpandedContent(homeScreenController, isMobile) : _buildCollapsedContent(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCollapsedContent() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _toggleExpansion,
        borderRadius: BorderRadius.circular(35),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColor.withOpacity(0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(35),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).primaryColor.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Effet de pulsation
              AnimatedBuilder(
                animation: _mainController,
                builder: (context, child) {
                  return Container(
                    width: 70 + (sin(_mainController.value * 2 * 3.14159) * 5),
                    height: 70 + (sin(_mainController.value * 2 * 3.14159) * 5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(35),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                  );
                },
              ),
              // Icône
              const Icon(
                Icons.menu_rounded,
                color: Colors.white,
                size: 30,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpandedContent(HomeScreenController controller, bool isMobile) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Header avec bouton de fermeture
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Navigation',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _toggleExpansion,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      color: Theme.of(context).primaryColor,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Items de navigation
          Expanded(
            child: AnimatedBuilder(
              animation: _itemsAnimation,
              builder: (context, child) {
                return ListView.builder(
                  itemCount: _items.length,
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    final delay = index * 0.1;
                    final animationValue = Curves.elasticOut.transform(
                      (_itemsAnimation.value - delay).clamp(0.0, 1.0),
                    );
                    
                    return Transform.translate(
                      offset: Offset((1 - animationValue) * 100, (1 - animationValue) * 30),
                      child: Transform.scale(
                        scale: animationValue,
                        child: Opacity(
                          opacity: animationValue,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Obx(() => _buildNavigationItem(
                              item,
                              controller.tabIndex.value == item.index,
                              () {
                                controller.onSideBarTabSelected(item.index);
                                // Fermer automatiquement après sélection sur mobile
                                if (MediaQuery.of(context).size.width < 480) {
                                  Future.delayed(const Duration(milliseconds: 300), () {
                                    _toggleExpansion();
                                  });
                                }
                              },
                              isMobile,
                            )),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationItem(
    SidebarItem item,
    bool isSelected,
    VoidCallback onTap,
    bool isMobile,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: isSelected ? item.gradient : null,
            color: isSelected ? null : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? Colors.transparent
                  : Theme.of(context).dividerColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withOpacity(0.2)
                      : Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  item.icon,
                  color: isSelected
                      ? Colors.white
                      : Theme.of(context).primaryColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item.label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isSelected
                        ? Colors.white
                        : Theme.of(context).textTheme.bodyMedium?.color,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
              if (isSelected)
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class SidebarItem {
  final IconData icon;
  final String label;
  final int index;
  final Gradient gradient;

  const SidebarItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.gradient,
  });
}