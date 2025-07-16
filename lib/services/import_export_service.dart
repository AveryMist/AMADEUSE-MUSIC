import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../utils/helper.dart';
import '../ui/widgets/snackbar.dart';

class ImportExportService extends GetxService {
  
  /// Export all user data to a JSON file
  Future<bool> exportData() async {
    try {
      printINFO("Starting data export...");

      // Show loading dialog
      if (Get.context != null) {
        showDialog(
          context: Get.context!,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text('preparingExport'.tr),
              ],
            ),
          ),
        );
      }

      // Collect all user data
      printINFO("Collecting user data...");
      final exportData = await _collectUserData();
      printINFO("User data collected: ${exportData.keys.length} categories");

      // Convert to JSON
      printINFO("Converting to JSON...");
      final jsonString = jsonEncode(exportData);
      printINFO("JSON created, size: ${jsonString.length} characters");

      // Close loading dialog
      if (Get.context != null && Navigator.of(Get.context!).canPop()) {
        Navigator.of(Get.context!).pop();
      }

      // Save file based on platform
      printINFO("Saving file...");
      String? outputPath;

      try {
        if (GetPlatform.isDesktop) {
          // Desktop: Use file picker to choose save location
          outputPath = await FilePicker.platform.saveFile(
            dialogTitle: 'exportAmadeuseMusicData'.tr,
            fileName: 'amadeuse_music_export_${DateTime.now().millisecondsSinceEpoch}.json',
            type: FileType.custom,
            allowedExtensions: ['json'],
          );

          if (outputPath == null) {
            printINFO("User cancelled file selection");
            if (Get.context != null) {
              ScaffoldMessenger.of(Get.context!).showSnackBar(
                snackbar(
                  Get.context!,
                  "exportCancelledByUser".tr,
                  size: SanckBarSize.MEDIUM
                )
              );
            }
            return false;
          }

          // Write JSON to file
          printINFO("Writing file to: $outputPath");
          final file = File(outputPath);
          await file.writeAsString(jsonString);

        } else {
          // Mobile: Use file picker with bytes
          final fileName = 'amadeuse_music_export_${DateTime.now().millisecondsSinceEpoch}.json';
          final bytes = utf8.encode(jsonString);

          outputPath = await FilePicker.platform.saveFile(
            dialogTitle: 'exportAmadeuseMusicData'.tr,
            fileName: fileName,
            type: FileType.custom,
            allowedExtensions: ['json'],
            bytes: bytes,
          );

          if (outputPath == null) {
            printINFO("User cancelled file selection");
            if (Get.context != null) {
              ScaffoldMessenger.of(Get.context!).showSnackBar(
                snackbar(
                  Get.context!,
                  "exportCancelledByUser".tr,
                  size: SanckBarSize.MEDIUM
                )
              );
            }
            return false;
          }

          printINFO("File saved via file picker with bytes");
        }

      } catch (e) {
        printERROR("File picker error: $e");
        if (Get.context != null) {
          ScaffoldMessenger.of(Get.context!).showSnackBar(
            snackbar(
              Get.context!,
              "Erreur lors de l'ouverture du sélecteur de fichier: $e",
              size: SanckBarSize.MEDIUM
            )
          );
        }
        return false;
      }

      printINFO("Data exported successfully to: $outputPath");

      // Show success message
      if (Get.context != null) {
        ScaffoldMessenger.of(Get.context!).showSnackBar(
          snackbar(
            Get.context!,
            "Données exportées avec succès !",
            size: SanckBarSize.MEDIUM
          )
        );
      }

      return true;

    } catch (e) {
      printERROR("Failed to export data: $e");

      // Close loading dialog if still open
      if (Get.context != null && Navigator.of(Get.context!).canPop()) {
        Navigator.of(Get.context!).pop();
      }

      if (Get.context != null) {
        ScaffoldMessenger.of(Get.context!).showSnackBar(
          snackbar(
            Get.context!,
            "Erreur lors de l'exportation: $e",
            size: SanckBarSize.MEDIUM
          )
        );
      }

      return false;
    }
  }
  
  /// Import user data from a JSON file
  Future<bool> importData() async {
    try {
      printINFO("Starting data import...");
      
      // Get file from user
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        dialogTitle: 'importAmadeuseMusicData'.tr,
      );
      
      if (result == null || result.files.single.path == null) {
        printINFO("No file selected for import");
        return false;
      }
      
      final file = File(result.files.single.path!);
      
      // Read and parse JSON
      final jsonString = await file.readAsString();
      final dynamic rawData = jsonDecode(jsonString);
      final Map<String, dynamic> importData = _convertToStringMap(rawData);

      // Validate import data
      if (!_validateImportData(importData)) {
        throw Exception("invalidImportFile".tr);
      }
      
      // Show confirmation dialog
      final confirmed = await _showImportConfirmationDialog(importData);
      if (!confirmed) {
        printINFO("Import cancelled by user");
        return false;
      }
      
      // Import the data
      await _importUserData(importData);
      
      printINFO("Data imported successfully");
      
      // Show success message
      if (Get.context != null) {
        ScaffoldMessenger.of(Get.context!).showSnackBar(
          snackbar(
            Get.context!,
            "dataImportedSuccessfully".tr,
            size: SanckBarSize.MEDIUM
          )
        );
      }
      
      return true;
      
    } catch (e) {
      printERROR("Failed to import data: $e");
      
      if (Get.context != null) {
        ScaffoldMessenger.of(Get.context!).showSnackBar(
          snackbar(
            Get.context!,
            "${'importError'.tr}: $e",
            size: SanckBarSize.MEDIUM
          )
        );
      }
      
      return false;
    }
  }
  
  /// Collect all user data for export
  Future<Map<String, dynamic>> _collectUserData() async {
    final data = <String, dynamic>{};
    
    // Add metadata
    data['exportVersion'] = '1.0';
    data['exportDate'] = DateTime.now().toIso8601String();
    data['appVersion'] = 'AMADEUSE MUSIC';
    
    // Export settings
    try {
      final settingsBox = await Hive.openBox('settings');
      data['settings'] = _convertToStringMap(settingsBox.toMap());
      await settingsBox.close();
    } catch (e) {
      printERROR("Failed to export settings: $e");
      data['settings'] = {};
    }
    
    // Export playlists
    try {
      final playlistsBox = await Hive.openBox('LibraryPlaylists');
      final playlistsData = _convertToStringMap(playlistsBox.toMap());
      data['playlists'] = playlistsData;

      printINFO("Found ${playlistsData.length} playlists to export");

      // Export playlist songs
      data['playlistSongs'] = <String, dynamic>{};
      int totalSongsExported = 0;

      for (final playlistEntry in playlistsData.entries) {
        final playlistId = playlistEntry.key;
        final playlistInfo = playlistEntry.value;

        printINFO("Exporting songs for playlist: $playlistId (${playlistInfo['title']})");

        try {
          final songsBox = await Hive.openBox(playlistId);
          final songsData = _convertToStringMap(songsBox.toMap());

          if (songsData.isNotEmpty) {
            data['playlistSongs'][playlistId] = songsData;
            totalSongsExported += songsData.length;
            printINFO("Exported ${songsData.length} songs for playlist '$playlistId'");
          } else {
            printINFO("Playlist '$playlistId' is empty");
            data['playlistSongs'][playlistId] = {};
          }

          await songsBox.close();
        } catch (e) {
          printERROR("Failed to export songs for playlist $playlistId: $e");
          data['playlistSongs'][playlistId] = {};
        }
      }

      printINFO("Total songs exported: $totalSongsExported across ${playlistsData.length} playlists");
      await playlistsBox.close();
    } catch (e) {
      printERROR("Failed to export playlists: $e");
      data['playlists'] = {};
      data['playlistSongs'] = {};
    }
    
    // Export favorite artists
    try {
      final artistsBox = await Hive.openBox('LibraryArtists');
      data['favoriteArtists'] = _convertToStringMap(artistsBox.toMap());
      await artistsBox.close();
    } catch (e) {
      printERROR("Failed to export favorite artists: $e");
      data['favoriteArtists'] = {};
    }
    
    // Export favorite albums
    try {
      final albumsBox = await Hive.openBox('LibraryAlbums');
      data['favoriteAlbums'] = _convertToStringMap(albumsBox.toMap());
      await albumsBox.close();
    } catch (e) {
      printERROR("Failed to export favorite albums: $e");
      data['favoriteAlbums'] = {};
    }
    
    return data;
  }
  
  /// Convert dynamic map to string-keyed map recursively
  Map<String, dynamic> _convertToStringMap(dynamic data) {
    try {
      if (data == null) return {};

      if (data is Map<String, dynamic>) {
        // Already correct type, but check nested values
        final Map<String, dynamic> result = {};
        data.forEach((key, value) {
          if (value is Map) {
            result[key] = _convertToStringMap(value);
          } else if (value is List) {
            result[key] = _convertToStringList(value);
          } else {
            result[key] = value;
          }
        });
        return result;
      }

      if (data is Map) {
        final Map<String, dynamic> result = {};
        data.forEach((key, value) {
          final String stringKey = key.toString();
          if (value is Map) {
            result[stringKey] = _convertToStringMap(value);
          } else if (value is List) {
            result[stringKey] = _convertToStringList(value);
          } else {
            result[stringKey] = value;
          }
        });
        return result;
      }

      // If not a Map, return empty map
      return {};
    } catch (e) {
      printERROR("Error converting map: $e");
      return {};
    }
  }

  /// Convert dynamic list recursively
  List<dynamic> _convertToStringList(List<dynamic> data) {
    try {
      return data.map((item) {
        if (item is Map) {
          return _convertToStringMap(item);
        } else if (item is List) {
          return _convertToStringList(item);
        } else {
          return item;
        }
      }).toList();
    } catch (e) {
      printERROR("Error converting list: $e");
      return [];
    }
  }

  /// Validate import data structure
  bool _validateImportData(Map<String, dynamic> data) {
    // Check required fields
    if (!data.containsKey('exportVersion') ||
        !data.containsKey('exportDate') ||
        !data.containsKey('settings')) {
      return false;
    }

    // Check version compatibility
    final version = data['exportVersion'] as String?;
    if (version != '1.0') {
      printINFO("Import data version $version may not be fully compatible");
    }

    return true;
  }
  
  /// Show confirmation dialog before importing
  Future<bool> _showImportConfirmationDialog(Map<String, dynamic> data) async {
    if (Get.context == null) return false;
    
    final playlistCount = (data['playlists'] as Map?)?.length ?? 0;
    final artistCount = (data['favoriteArtists'] as Map?)?.length ?? 0;
    final albumCount = (data['favoriteAlbums'] as Map?)?.length ?? 0;
    
    return await showDialog<bool>(
      context: Get.context!,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer l\'importation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Cette opération va importer:'),
            const SizedBox(height: 10),
            Text('• $playlistCount playlists'),
            Text('• $artistCount artistes favoris'),
            Text('• $albumCount albums favoris'),
            Text('• Paramètres de l\'application'),
            const SizedBox(height: 15),
            const Text(
              'Les données existantes seront fusionnées avec les nouvelles données. '
              'Cette opération ne peut pas être annulée.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Importer'),
          ),
        ],
      ),
    ) ?? false;
  }
  
  /// Import user data from parsed JSON
  Future<void> _importUserData(Map<String, dynamic> data) async {
    // Map to track playlist ID changes for merging
    final Map<String, String> playlistMergeMap = {};
    // Import settings (merge with existing)
    if (data.containsKey('settings')) {
      final settingsBox = await Hive.openBox('settings');
      final dynamic rawSettings = data['settings'];
      final Map<String, dynamic> importSettings = _convertToStringMap(rawSettings);

      for (final entry in importSettings.entries) {
        await settingsBox.put(entry.key, entry.value);
      }

      await settingsBox.close();
      printINFO("Settings imported successfully");
    }
    
    // Import playlists with intelligent merging
    if (data.containsKey('playlists')) {
      final playlistsBox = await Hive.openBox('LibraryPlaylists');
      final dynamic rawPlaylists = data['playlists'];
      final Map<String, dynamic> importPlaylists = _convertToStringMap(rawPlaylists);
      final existingPlaylists = _convertToStringMap(playlistsBox.toMap());

      printINFO("Importing ${importPlaylists.length} playlists...");

      for (final playlistEntry in importPlaylists.entries) {
        final importPlaylistId = playlistEntry.key;
        final importPlaylistData = _convertToStringMap(playlistEntry.value);
        final importPlaylistTitle = importPlaylistData['title'] as String;

        // Check if a playlist with the same name already exists
        String? existingPlaylistId;
        for (final existingEntry in existingPlaylists.entries) {
          final existingData = _convertToStringMap(existingEntry.value);
          if (existingData['title'] == importPlaylistTitle) {
            existingPlaylistId = existingEntry.key;
            break;
          }
        }

        if (existingPlaylistId != null) {
          printINFO("Found existing playlist with same name '$importPlaylistTitle', will merge songs");
          // Map the import ID to the existing ID for song merging
          playlistMergeMap[importPlaylistId] = existingPlaylistId;
        } else {
          // Create new playlist with new ID to avoid conflicts
          final newPlaylistId = "LIB${DateTime.now().millisecondsSinceEpoch}";
          final newPlaylistData = _convertToStringMap(importPlaylistData);
          newPlaylistData['playlistId'] = newPlaylistId;

          await playlistsBox.put(newPlaylistId, newPlaylistData);
          playlistMergeMap[importPlaylistId] = newPlaylistId;
          printINFO("Created new playlist '$importPlaylistTitle' with ID $newPlaylistId");

          // Add a small delay to ensure unique timestamps
          await Future.delayed(const Duration(milliseconds: 1));
        }
      }

      await playlistsBox.close();
      printINFO("Playlists imported successfully");
    }
    
    // Import playlist songs with merging
    if (data.containsKey('playlistSongs')) {
      final playlistSongs = _convertToStringMap(data['playlistSongs']);
      int totalSongsImported = 0;

      for (final playlistEntry in playlistSongs.entries) {
        final importPlaylistId = playlistEntry.key;
        final importSongs = _convertToStringMap(playlistEntry.value);

        // Get the target playlist ID (either existing for merge or new)
        final targetPlaylistId = playlistMergeMap[importPlaylistId];
        if (targetPlaylistId == null) {
          printERROR("No target playlist found for import playlist $importPlaylistId");
          continue;
        }

        try {
          final songsBox = await Hive.openBox(targetPlaylistId);

          // Get existing songs to avoid duplicates
          final existingSongs = Map<String, dynamic>.from(songsBox.toMap());
          final existingSongIds = existingSongs.values
              .map((song) => song['videoId'] as String?)
              .where((id) => id != null)
              .toSet();

          int songsAdded = 0;
          int nextIndex = existingSongs.length;

          for (final songEntry in importSongs.entries) {
            final songData = songEntry.value as Map<String, dynamic>;
            final songId = songData['videoId'] as String?;

            // Only add if song doesn't already exist
            if (songId != null && !existingSongIds.contains(songId)) {
              await songsBox.put(nextIndex, songData);
              nextIndex++;
              songsAdded++;
              totalSongsImported++;
            }
          }

          await songsBox.close();
          printINFO("Added $songsAdded new songs to playlist $targetPlaylistId (${existingSongs.length} existing)");

        } catch (e) {
          printERROR("Failed to import songs for playlist $importPlaylistId -> $targetPlaylistId: $e");
        }
      }

      printINFO("Playlist songs imported successfully: $totalSongsImported total songs added");
    }
    
    // Import favorite artists
    if (data.containsKey('favoriteArtists')) {
      final artistsBox = await Hive.openBox('LibraryArtists');
      final importArtists = data['favoriteArtists'] as Map<String, dynamic>;
      
      for (final entry in importArtists.entries) {
        await artistsBox.put(entry.key, entry.value);
      }
      
      await artistsBox.close();
      printINFO("Favorite artists imported successfully");
    }
    
    // Import favorite albums
    if (data.containsKey('favoriteAlbums')) {
      final albumsBox = await Hive.openBox('LibraryAlbums');
      final importAlbums = data['favoriteAlbums'] as Map<String, dynamic>;
      
      for (final entry in importAlbums.entries) {
        await albumsBox.put(entry.key, entry.value);
      }
      
      await albumsBox.close();
      printINFO("Favorite albums imported successfully");
    }
  }
}
