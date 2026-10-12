import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'gazette_style.dart';

class DetailsScreen extends StatefulWidget {
  const DetailsScreen({super.key});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  String message = '';
  bool messageSuccess = true;

  @override
  Widget build(BuildContext context) {
    final post =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final box = Hive.box('favoritesBox');

    // Is this post already saved? If yes, get its note
    final isSaved = box.containsKey(post['id']);
    final savedPost = box.get(post['id']);
    final savedNote = savedPost != null ? savedPost['note'].toString() : '';

    // Word count and reading time
    final bodyText = post['body'].toString().replaceAll('\n', ' ');
    final wordCount = bodyText.split(' ').length;
    final minutes = (wordCount / 200).ceil();

    return Scaffold(
      appBar: AppBar(
        title: Text('POST DETAILS', style: labelStyle(size: 13, color: inkColor)),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: lineColor),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(22, 20, 22, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(child: Text('FEATURED POST', style: labelStyle(size: 11))),
            const SizedBox(height: 12),
            Text(
              post['title'].toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w900,
                height: 1.15,
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                'POST #${post['id']}',
                style: labelStyle(size: 11, color: oliveColor),
              ),
            ),
            const SizedBox(height: 4),
            Center(
              child: Text(
                '$wordCount WORDS  ·  $minutes MIN READ',
                style: labelStyle(size: 9, color: softInk),
              ),
            ),
            const SizedBox(height: 16),
            Container(height: 1, color: lineColor),
            const SizedBox(height: 18),

            // Body text
            Text(
              bodyText,
              style: const TextStyle(fontSize: 17, height: 1.7),
            ),

            const SizedBox(height: 18),
            Container(height: 1, color: lineColor),
            const SizedBox(height: 18),

            // Shows the saved note when this post is a favorite
            if (isSaved)
              PaperCard(
                margin: const EdgeInsets.only(bottom: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('MY NOTE', style: labelStyle(size: 10)),
                    const SizedBox(height: 6),
                    Text(
                      savedNote.isEmpty ? 'No note yet' : savedNote,
                      style: TextStyle(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: savedNote.isEmpty ? softInk : inkColor,
                      ),
                    ),
                  ],
                ),
              ),

            ElevatedButton.icon(
              icon: Icon(isSaved ? Icons.bookmark : Icons.bookmark_border),
              label: Text(isSaved ? 'SAVED IN FAVORITES' : 'SAVE TO FAVORITES'),
              onPressed: () {
                // Create (id is the key, so no duplicates)
                if (box.containsKey(post['id'])) {
                  setState(() {
                    messageSuccess = false;
                    message = 'Already in favorites.';
                  });
                } else {
                  box.put(post['id'], {
                    'id': post['id'],
                    'title': post['title'],
                    'body': post['body'],
                    'note': '',
                  });
                  setState(() {
                    messageSuccess = true;
                    message = 'Saved to favorites!';
                  });
                }
              },
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              icon: const Icon(Icons.arrow_back),
              label: const Text('BACK'),
              onPressed: () => Navigator.pop(context),
            ),
            if (message.isNotEmpty) ...[
              const SizedBox(height: 16),
              MessageBanner(text: message, success: messageSuccess),
            ],
          ],
        ),
      ),
    );
  }
}