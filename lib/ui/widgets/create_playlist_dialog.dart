import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:get/Get.dart';
import 'package:hive/hive.dart';
import 'package:widget_marquee/widget_marquee.dart';
import 'package:flutter/foundation.dart';
import 'dart:isolate';
import 'package:hive_flutter/hive_flutter.dart';

import '/services/piped_service.dart';
import '../screens/Library/library_controller.dart';
import '/ui/widgets/snackbar.dart';
import '../../models/playlist.dart';
import '../../models/media_item_builder.dart';
import 'common_dialog_widget.dart';
import 'modified_text_field.dart';

class CreateNRenamePlaylistPopup extends StatelessWidget {
  const CreateNRenamePlaylistPopup(
      {super.key,
      this.isCreateNadd = false,
      this.songItems,
      this.renamePlaylist = false,
      this.playlist});
  final bool isCreateNadd;
  final bool renamePlaylist;
  final List<MediaItem>? songItems;
  final Playlist? playlist;

  @override
  Widget build(BuildContext context) {
    final librPlstCntrller = Get.find<LibraryPlaylistsController>();
    librPlstCntrller.changeCreationMode("local");
    librPlstCntrller.textInputController.text = "";
    final isPipedLinked = Get.find<PipedServices>().isLoggedIn;
    return CommonDialog(
      child: Container(
        height: (isPipedLinked && !renamePlaylist) ? 245 : 200,
        padding:
            const EdgeInsets.only(top: 30, left: 30, right: 30, bottom: 10),
        child: Stack(
          children: [
            Column(children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Marquee(
                    delay: const Duration(milliseconds: 300),
                    id: "createPlaylist",
                    child: Text(
                      renamePlaylist
                          ? "renamePlaylist".tr
                          : "CreateNewPlaylist".tr,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ),
              ),
              if (isPipedLinked && !renamePlaylist)
                Obx(
                  () => Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Radio(
                              value: "piped",
                              groupValue:
                                  librPlstCntrller.playlistCreationMode.value,
                              onChanged: librPlstCntrller.changeCreationMode),
                          Text("Piped".tr),
                        ],
                      ),
                      const SizedBox(
                        width: 15,
                      ),
                      Row(
                        children: [
                          Radio(
                              value: "local",
                              groupValue:
                                  librPlstCntrller.playlistCreationMode.value,
                              onChanged: librPlstCntrller.changeCreationMode),
                          Text("local".tr),
                        ],
                      )
                    ],
                  ),
                ),
              ModifiedTextField(
                textCapitalization: TextCapitalization.sentences,
                autofocus: true,
                cursorColor: Theme.of(context).textTheme.titleSmall!.color,
                controller: librPlstCntrller.textInputController,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.only(left: 5),
                  focusColor: Colors.white,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    InkWell(
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text("cancel".tr),
                      ),
                      onTap: () => Navigator.of(context).pop(),
                    ),
                    if (!renamePlaylist) ...[
                      Container(
                        decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(10)),
                        child: InkWell(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15.0, vertical: 10),
                            child: Text(
                              "dynamic".tr,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          onTap: () async {
                            Navigator.of(context).pop();
                            _showDynamicPlaylistDialog(context, librPlstCntrller);
                          },
                        ),
                      ),
                    ],
                    Container(
                      decoration: BoxDecoration(
                          color: Theme.of(context).textTheme.titleLarge!.color,
                          borderRadius: BorderRadius.circular(10)),
                      child: InkWell(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15.0, vertical: 10),
                          child: Text(
                            isCreateNadd
                                ? "createnAdd".tr
                                : renamePlaylist
                                    ? "rename".tr
                                    : "create".tr,
                            style:
                                TextStyle(color: Theme.of(context).canvasColor),
                          ),
                        ),
                        onTap: () async {
                          if (renamePlaylist) {
                            librPlstCntrller
                                .renamePlaylist(playlist!)
                                .then((value) {
                              if (value) {
                                if (!context.mounted) return;
                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                    snackbar(context, "playlistRenameAlert".tr,
                                        size: SanckBarSize.MEDIUM));
                              }
                            });
                          } else {
                            librPlstCntrller
                                .createNewPlaylist(
                                    createPlaylistNaddSong: isCreateNadd,
                                    songItems: songItems)
                                .then((value) {
                              if (!context.mounted) return;
                              if (value) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    snackbar(
                                        context,
                                        isCreateNadd
                                            ? "playlistCreatednsongAddedAlert"
                                                .tr
                                            : "playlistCreatedAlert".tr,
                                        size: SanckBarSize.MEDIUM));
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    snackbar(context, "errorOccuredAlert".tr,
                                        size: SanckBarSize.MEDIUM));
                              }
                              Navigator.of(context).pop();
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
              )
            ]),
            Obx(() =>
                (librPlstCntrller.creationInProgress.isTrue && isPipedLinked)
                    ? const Positioned(
                        top: 5,
                        right: 8,
                        child: SizedBox(
                            height: 15,
                            width: 15,
                            child: CircularProgressIndicator(
                              backgroundColor: Colors.transparent,
                              strokeWidth: 2,
                            )),
                      )
                    : const SizedBox.shrink()),
          ],
        ),
      ),
    );
  }
}

void _showDynamicPlaylistDialog(BuildContext context, LibraryPlaylistsController librPlstCntrller) {
  showDialog(
    context: context,
    builder: (context) => DynamicPlaylistDialog(librPlstCntrller: librPlstCntrller),
  );
}

class DynamicPlaylistDialog extends StatefulWidget {
  final LibraryPlaylistsController librPlstCntrller;
  
  const DynamicPlaylistDialog({super.key, required this.librPlstCntrller});
  
  @override
  State<DynamicPlaylistDialog> createState() => _DynamicPlaylistDialogState();
}

class _DynamicPlaylistDialogState extends State<DynamicPlaylistDialog> {
  final TextEditingController _nameController = TextEditingController();
  Set<String> _selectedTags = {};
  List<String> _availableTags = [];
  bool _isLoading = true;
  String _loadingProgress = '';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _loadAvailableTags();
  }
  
  Future<void> _loadAvailableTags() async {
    setState(() {
      _isLoading = true;
      _loadingProgress = 'Initialisation...';
    });
    
    final receivePort = ReceivePort();
    await Isolate.spawn(_extractTagsIsolate, receivePort.sendPort);
    
    receivePort.listen((message) {
      if (message is String) {
        setState(() { _loadingProgress = message; });
      } else if (message is List<String>) {
        setState(() {
          _availableTags = message;
          _isLoading = false;
        });
        receivePort.close();
      }
    });
  }
  
  static Future<void> _extractTagsIsolate(SendPort sendPort) async {
    await Hive.initFlutter();
    final playlistsBox = await Hive.openBox('playlists');
    final Set<String> allTags = {};
    final totalPlaylists = playlistsBox.keys.length;
    int processed = 0;
    
    for (final playlistKey in playlistsBox.keys) {
      sendPort.send('Traitement de la playlist $processed/$totalPlaylists...');
      final playlistData = playlistsBox.get(playlistKey);
      if (playlistData != null && playlistData['songs'] != null) {
        final songs = List<Map<String, dynamic>>.from(playlistData['songs']);
        for (final songData in songs) {
          try {
            final mediaItem = MediaItemBuilder.fromJson(songData);
            final tags = _extractAllTagsFromMediaItem(mediaItem);
            allTags.addAll(tags);
          } catch (e) {
            print('Erreur lors de l\'extraction des tags: $e');
          }
        }
      }
      processed++;
    }
    
    final sortedTags = allTags.toList()..sort();
    sendPort.send(sortedTags);
  }
  
  static Future<List<String>> _extractTagsFromAllPlaylists() async {
    final Set<String> allTags = {};
    final playlistsBox = Hive.box('playlists');
    
    // Parcourir TOUTES les playlists pour extraire les tags
    for (final playlistKey in playlistsBox.keys) {
      final playlistData = playlistsBox.get(playlistKey);
      if (playlistData != null && playlistData['songs'] != null) {
        final songs = List<Map<String, dynamic>>.from(playlistData['songs']);
        
        for (final songData in songs) {
           try {
             final mediaItem = MediaItemBuilder.fromJson(songData);
             final tags = _extractAllTagsFromMediaItem(mediaItem);
             allTags.addAll(tags);
           } catch (e) {
             // Ignorer les erreurs de parsing
             print('Erreur lors de l\'extraction des tags: $e');
           }
         }
      }
    }
    
    return allTags.toList()..sort();
  }
  
  static List<String> _extractAllTagsFromMediaItem(MediaItem mediaItem) {
    final Set<String> tags = {};
    
    // Extraire TOUS les mots-clés possibles depuis le titre
    final title = mediaItem.title.toLowerCase();
    final splitTitleWords = title.split(RegExp(r'[\s\-_,\.;:!\?]+'));
    
    final filteredTitleWords = <String>[];
    for (final word in splitTitleWords) {
      final trimmedWord = word.trim();
      if (trimmedWord.length > 2 && trimmedWord.isNotEmpty) {
        filteredTitleWords.add(trimmedWord);
      }
    }
    
    for (final word in filteredTitleWords) {
      tags.add(word.toUpperCase());
    }
    
    // Extraire depuis l'artiste - TOUS les mots
    if (mediaItem.artist != null && mediaItem.artist!.isNotEmpty) {
      final splitArtistWords = mediaItem.artist!.toLowerCase()
          .split(RegExp(r'[\s\-_,\.;:!\?]+'));
      
      final filteredArtistWords = <String>[];
      for (final word in splitArtistWords) {
        final trimmedWord = word.trim();
        if (trimmedWord.length > 1 && trimmedWord.isNotEmpty) {
          filteredArtistWords.add(trimmedWord);
        }
      }
      
      for (final word in filteredArtistWords) {
        tags.add('ARTIST_${word.toUpperCase()}');
      }
      
      // Ajouter l'artiste complet comme tag
      tags.add('ARTIST_${mediaItem.artist!.toUpperCase()}');
    }
    
    // Extraire depuis l'album - TOUS les mots
    if (mediaItem.album != null && mediaItem.album!.isNotEmpty) {
      final splitAlbumWords = mediaItem.album!.toLowerCase()
          .split(RegExp(r'[\s\-_,\.;:!\?]+'));
      
      final filteredAlbumWords = <String>[];
      for (final word in splitAlbumWords) {
        final trimmedWord = word.trim();
        if (trimmedWord.length > 2 && trimmedWord.isNotEmpty) {
          filteredAlbumWords.add(trimmedWord);
        }
      }
      
      for (final word in filteredAlbumWords) {
        tags.add('ALBUM_${word.toUpperCase()}');
      }
    }
    
    // Extraire depuis les extras (métadonnées YouTube)
    if (mediaItem.extras != null) {
      final extras = mediaItem.extras!;
      
      // Année
      if (extras['year'] != null) {
        tags.add('YEAR_${extras['year']}');
      }
      
      // Genre (si disponible)
      if (extras['genre'] != null) {
        tags.add('GENRE_${extras['genre'].toString().toUpperCase()}');
      }
      
      // Durée (catégories)
      if (mediaItem.duration != null) {
        final minutes = mediaItem.duration!.inMinutes;
        if (minutes < 3) {
          tags.add('DURATION_SHORT');
        } else if (minutes < 6) {
          tags.add('DURATION_MEDIUM');
        } else {
          tags.add('DURATION_LONG');
        }
      }
      
      // Autres métadonnées possibles
      extras.forEach((key, value) {
        if (value != null && value.toString().isNotEmpty) {
          final splitWords = value.toString().toLowerCase()
              .split(RegExp(r'[\s\-_,\.;:!\?]+'));
          
          final filteredWords = <String>[];
          for (final word in splitWords) {
            final trimmedWord = word.trim();
            if (trimmedWord.length > 2 && trimmedWord.isNotEmpty) {
              filteredWords.add(trimmedWord);
            }
          }
          
          for (final word in filteredWords) {
            tags.add('${key.toUpperCase()}_${word.toUpperCase()}');
          }
        }
      });
    }
    
    // Tags de genres musicaux étendus
    final allGenres = [
      'phonk', 'rap', 'hip hop', 'hiphop', 'rock', 'pop', 'electronic', 'jazz', 'blues',
      'classical', 'country', 'reggae', 'metal', 'punk', 'folk', 'r&b', 'rnb', 'soul',
      'funk', 'disco', 'house', 'techno', 'trance', 'dubstep', 'drum and bass', 'dnb',
      'ambient', 'chill', 'lofi', 'lo-fi', 'trap', 'drill', 'afrobeat', 'latin', 'reggaeton',
      'indie', 'alternative', 'grunge', 'punk rock', 'hard rock', 'heavy metal', 'death metal',
      'black metal', 'thrash metal', 'progressive', 'psychedelic', 'garage', 'surf',
      'ska', 'swing', 'bebop', 'fusion', 'smooth jazz', 'acid jazz', 'nu jazz',
      'gospel', 'spiritual', 'hymn', 'choir', 'orchestra', 'symphony', 'opera',
      'bluegrass', 'folk rock', 'celtic', 'world music', 'ethnic', 'traditional',
      'experimental', 'noise', 'industrial', 'synthwave', 'vaporwave', 'chillwave',
      'future bass', 'melodic dubstep', 'hardstyle', 'hardcore', 'gabber', 'breakbeat',
      'jungle', 'liquid dnb', 'neurofunk', 'minimal', 'deep house', 'tech house',
      'progressive house', 'electro house', 'big room', 'future house', 'bass house',
      'uk garage', 'grime', 'drill uk', 'afro house', 'amapiano', 'baile funk',
      'reggaeton', 'dembow', 'moombahton', 'tropical house', 'dancehall', 'soca',
      'calypso', 'merengue', 'salsa', 'bachata', 'cumbia', 'vallenato', 'tango',
      'flamenco', 'fado', 'bossa nova', 'samba', 'forró', 'axé', 'pagode', 'sertanejo',
      'k-pop', 'j-pop', 'c-pop', 'bollywood', 'qawwali', 'ghazal', 'sufi', 'devotional',
      'mantra', 'meditation', 'new age', 'healing', 'nature sounds', 'white noise',
      'binaural', 'asmr', 'podcast', 'audiobook', 'comedy', 'spoken word'
    ];
    
    // Vérifier tous les genres dans le titre, artiste et album
    final fullText = '${mediaItem.title} ${mediaItem.artist ?? ''} ${mediaItem.album ?? ''}'.toLowerCase();
    for (final genre in allGenres) {
      if (fullText.contains(genre)) {
        tags.add('GENRE_${genre.toUpperCase().replaceAll(' ', '_')}');
      }
    }
    
    return tags.toList();
  }
  
  bool _isTagMatch(String songTag, String selectedTag) {
    // Correspondance exacte
    if (songTag == selectedTag) return true;
    
    // Correspondance partielle pour les genres
    if (songTag.startsWith('genre_') && selectedTag.startsWith('genre_')) {
      return songTag.contains(selectedTag.replaceFirst('genre_', '')) ||
             selectedTag.contains(songTag.replaceFirst('genre_', ''));
    }
    
    // Correspondance pour les artistes
    if (songTag.startsWith('artist_') && selectedTag.startsWith('artist_')) {
      return songTag.contains(selectedTag.replaceFirst('artist_', '')) ||
             selectedTag.contains(songTag.replaceFirst('artist_', ''));
    }
    
    // Correspondance pour les albums
    if (songTag.startsWith('album_') && selectedTag.startsWith('album_')) {
      return songTag.contains(selectedTag.replaceFirst('album_', '')) ||
             selectedTag.contains(songTag.replaceFirst('album_', ''));
    }
    
    // Correspondance générale (mots similaires)
    return songTag.contains(selectedTag) || selectedTag.contains(songTag);
  }
  
  Future<void> _createDynamicPlaylist() async {
    if (_nameController.text.trim().isEmpty || _selectedTags.isEmpty) {
      return;
    }
    
    final playlistName = _nameController.text.trim();
    
    // Collecter toutes les chansons avec les tags sélectionnés
    final Set<MediaItem> matchingSongs = {};
    final playlistsBox = Hive.box('playlists');
    
    // Parcourir TOUTES les playlists pour trouver toutes les musiques
    for (final playlistKey in playlistsBox.keys) {
      final playlistData = playlistsBox.get(playlistKey);
      if (playlistData != null && playlistData['songs'] != null) {
        final songs = List<Map<String, dynamic>>.from(playlistData['songs']);
        
        for (final songData in songs) {
           try {
             final mediaItem = MediaItemBuilder.fromJson(songData);
             final songTags = _extractAllTagsFromMediaItem(mediaItem);
             
             // Vérifier si la chanson contient au moins un des tags sélectionnés
             bool hasMatchingTags = false;
             
             for (final selectedTag in _selectedTags) {
               final selectedTagLower = selectedTag.toLowerCase();
               hasMatchingTags = songTags.any((songTag) {
                 final songTagLower = songTag.toLowerCase();
                 return songTagLower.contains(selectedTagLower) ||
                        selectedTagLower.contains(songTagLower) ||
                        _isTagMatch(songTagLower, selectedTagLower);
               });
               
               if (hasMatchingTags) break;
             }
             
             if (hasMatchingTags) {
               matchingSongs.add(mediaItem);
             }
           } catch (e) {
             // Ignorer les erreurs de parsing
             print('Erreur lors du parsing de la chanson: $e');
           }
         }
      }
    }
    
    if (matchingSongs.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Aucune chanson trouvée avec les tags sélectionnés'))
        );
      }
      return;
    }
    
    // Créer la playlist dynamique
    final tagsString = _selectedTags.join(', ');
    final newPlaylist = Playlist(
      title: '$playlistName (Dynamique)',
      playlistId: 'LIBDYN${DateTime.now().millisecondsSinceEpoch}',
      thumbnailUrl: matchingSongs.isNotEmpty 
          ? matchingSongs.first.artUri.toString() 
          : Playlist.thumbPlaceholderUrl,
      description: 'Playlist dynamique basée sur les tags: $tagsString',
      isCloudPlaylist: false,
    );
    
    // Sauvegarder la playlist
    final libraryBox = await Hive.openBox('LibraryPlaylists');
    await libraryBox.put(newPlaylist.playlistId, newPlaylist.toJson());
    await libraryBox.close();
    
    // Ajouter les chansons à la playlist
    final playlistBox = await Hive.openBox(newPlaylist.playlistId);
    for (final song in matchingSongs) {
      await playlistBox.add(MediaItemBuilder.toJson(song));
    }
    await playlistBox.close();
    
    // Mettre à jour la liste des playlists
    widget.librPlstCntrller.refreshLib();
    
    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Playlist dynamique "$playlistName" créée avec ${matchingSongs.length} chansons'),
          backgroundColor: Colors.green,
        )
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return CommonDialog(
      child: Container(
        height: 400,
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Créer une Playlist Dynamique',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 20),
            ModifiedTextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nom de la playlist',
                contentPadding: EdgeInsets.only(left: 5),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Text(
                  'Sélectionner des tags:',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const Spacer(),
                Text(
                  '${_selectedTags.length} sélectionné(s)',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Barre de recherche
            ModifiedTextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Rechercher un tag...',
                prefixIcon: Icon(Icons.search),
                contentPadding: EdgeInsets.only(left: 5),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _isLoading
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 10),
                          Text(_loadingProgress),
                        ],
                      ),
                    )
                  : _availableTags.isEmpty
                      ? const Center(
                          child: Text('Aucun tag trouvé dans vos playlists')
                        )
                      : ListView.builder(
                          itemCount: _filteredTags.length,
                          itemBuilder: (context, index) {
                            final tag = _filteredTags[index];
                            final isSelected = _selectedTags.contains(tag);
                            return CheckboxListTile(
                              title: Text(
                                tag,
                                style: TextStyle(
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  color: isSelected ? Colors.orange : null,
                                ),
                              ),
                              value: isSelected,
                              onChanged: (bool? value) {
                                setState(() {
                                  if (value == true) {
                                    _selectedTags.add(tag);
                                  } else {
                                    _selectedTags.remove(tag);
                                  }
                                });
                              },
                              activeColor: Colors.orange,
                            );
                          },
                        ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Annuler'),
                ),
                ElevatedButton(
                  onPressed: _nameController.text.trim().isNotEmpty && _selectedTags.isNotEmpty
                      ? _createDynamicPlaylist
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                  child: Text('Créer'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  List<String> get _filteredTags {
    if (_searchQuery.isEmpty) {
      return _availableTags;
    }
    return _availableTags
        .where((tag) => tag.toLowerCase().contains(_searchQuery))
        .toList();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}
