import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'help_controller.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final HelpController helpController = Get.put(HelpController());
    
    return Scaffold(
      appBar: AppBar(
        title: Text('help'.tr),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: helpController.searchController,
              decoration: InputDecoration(
                hintText: 'helpSearchHint'.tr,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: Obx(() => helpController.searchQuery.value.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: helpController.clearSearch,
                      )
                    : const SizedBox.shrink()),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Theme.of(context).cardColor,
              ),
            ),
          ),
          
          // Content
          Expanded(
            child: Obx(() {
              if (helpController.searchQuery.value.isNotEmpty) {
                return _buildSearchResults(helpController);
              } else if (helpController.selectedCategory.value.isNotEmpty) {
                return _buildCategoryContent(helpController);
              } else {
                return _buildCategoryList(helpController);
              }
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryList(HelpController helpController) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: helpController.helpCategories.length,
      itemBuilder: (context, index) {
        final category = helpController.helpCategories[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Icon(
              category.iconData,
              color: Theme.of(context).primaryColor,
              size: 28,
            ),
            title: Text(
              category.titleKey.tr,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              '${category.sections.length} ${'helpSections'.tr}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => helpController.selectCategory(category.id),
          ),
        );
      },
    );
  }

  Widget _buildCategoryContent(HelpController helpController) {
    final category = helpController.getCategoryById(helpController.selectedCategory.value);
    if (category == null) return const SizedBox.shrink();

    return Column(
      children: [
        // Category Header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(Get.context!).primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => helpController.selectedCategory.value = '',
              ),
              Icon(
                category.iconData,
                color: Theme.of(Get.context!).primaryColor,
                size: 32,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  category.titleKey.tr,
                  style: Theme.of(Get.context!).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(Get.context!).primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Sections List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: category.sections.length,
            itemBuilder: (context, index) {
              final section = category.sections[index];
              return _buildSectionCard(section, helpController);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchResults(HelpController helpController) {
    final filteredSections = helpController.getFilteredSections();
    
    if (filteredSections.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Theme.of(Get.context!).disabledColor,
            ),
            const SizedBox(height: 16),
            Text(
              'helpNoResults'.tr,
              style: Theme.of(Get.context!).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'helpTryDifferentKeywords'.tr,
              style: Theme.of(Get.context!).textTheme.bodyMedium?.copyWith(
                color: Theme.of(Get.context!).disabledColor,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: filteredSections.length,
      itemBuilder: (context, index) {
        final section = filteredSections[index];
        return _buildSectionCard(section, helpController);
      },
    );
  }

  Widget _buildSectionCard(HelpSection section, HelpController helpController) {
    return Obx(() {
      final isExpanded = helpController.expandedSections.contains(section.id);
      
      return Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: Column(
          children: [
            ListTile(
              title: Text(
                section.titleKey.tr,
                style: Theme.of(Get.context!).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              trailing: Icon(
                isExpanded ? Icons.expand_less : Icons.expand_more,
              ),
              onTap: () => helpController.toggleSection(section.id),
            ),
            if (isExpanded)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Text(
                  section.contentKey.tr,
                  style: Theme.of(Get.context!).textTheme.bodyMedium?.copyWith(
                    height: 1.5,
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }
}
