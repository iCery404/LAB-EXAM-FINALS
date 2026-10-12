import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'gazette_style.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  // Update the note
  void editNote(BuildContext context, Box box, Map post) {
    final noteController = TextEditingController(text: post['note']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: paperColor,
          title: const Text(
            'EDIT NOTE',
            style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2),
          ),
          content: TextField(
            controller: noteController,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Personal note'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final updated = Map.from(post);
                updated['note'] = noteController.text;
                box.put(post['id'], updated);
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // Delete, then show a snackbar with UNDO
  void deletePost(BuildContext context, Box box, Map post) {
    box.delete(post['id']);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Removed from favorites'),
        action: SnackBarAction(
          label: 'UNDO',
          textColor: const Color(0xFFE8A27C),
          onPressed: () => box.put(post['id'], post),
        ),
      ),
    );
  }

  // Open the favorite on the details screen
  void openFavorite(BuildContext context, Map post) {
    Navigator.pushNamed(
      context,
      '/details',
      arguments: {
        'id': post['id'],
        'title': post['title'],
        'body': post['body'],
      },
    );
  }

  // Rounded pill counter
  Widget pill(String text, bool filled) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: filled ? rustColor : Colors.transparent,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: filled ? rustColor : oliveColor),
      ),
      child: Text(
        text,
        style: labelStyle(
          size: 9,
          color: filled ? Colors.white : oliveColor,
        ),
      ),
    );
  }

  // One saved post card (tap to view)
  Widget buildFavoriteCard(BuildContext context, Box box, Map post) {
    final hasNote = post['note'] != '';

    return PaperCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(14),
      onTap: () => openFavorite(context, post),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'POST #${post['id']}',
                style: labelStyle(size: 10, color: oliveColor),
              ),
              const Icon(Icons.bookmark, color: rustColor, size: 20),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Text(
              post['title'].toString(),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                height: 1.2,
              ),
            ),
          ),
          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(vertical: 6),
            color: lineColor,
          ),
          Text(
            hasNote ? post['note'].toString() : 'No note yet',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              fontStyle: FontStyle.italic,
              color: hasNote ? inkColor : softInk,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () => editNote(context, box, post),
                child: const Icon(Icons.edit, color: rustColor, size: 20),
              ),
              const SizedBox(width: 16),
              GestureDetector(
                // Delete
                onTap: () => deletePost(context, box, post),
                child: const Icon(
                  Icons.delete,
                  color: Color(0xFFA23B2A),
                  size: 20,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Last tile: goes back to the posts list
  Widget buildAddTile(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFEDE6D9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: lineColor, width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_circle_outline, color: softInk, size: 32),
            const SizedBox(height: 8),
            Text('ADD MORE POSTS', style: labelStyle(size: 10, color: softInk)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final box = Hive.box('favoritesBox');

    return Scaffold(
      appBar: AppBar(title: const Text('FAVORITES')),
      body: ValueListenableBuilder(
        valueListenable: box.listenable(),
        builder: (context, Box box, _) {
          // Read
          final favorites = box.values.toList();
          final notesCount =
              favorites.where((p) => (p as Map)['note'] != '').length;

          return Column(
            children: [
              const Masthead(
                title: 'MY FAVORITES',
                subtitle: 'SAVED POSTS AND PERSONAL NOTES',
              ),
              Wrap(
                spacing: 8,
                children: [
                  pill('ALL SAVED · ${favorites.length}', true),
                  pill('WITH NOTES · $notesCount', false),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: favorites.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.bookmark_border,
                                size: 70, color: rustColor),
                            SizedBox(height: 12),
                            Text(
                              'No favorites saved yet.',
                              style: TextStyle(fontSize: 16, color: softInk),
                            ),
                          ],
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.82,
                        ),
                        itemCount: favorites.length + 1,
                        itemBuilder: (context, index) {
                          if (index == favorites.length) {
                            return buildAddTile(context);
                          }
                          final post = favorites[index] as Map;
                          return buildFavoriteCard(context, box, post);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}