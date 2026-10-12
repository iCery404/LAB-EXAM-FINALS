import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'gazette_style.dart';

const String apiUrl = 'https://6acca8dcb406cb8ec0c633ef.mockapi.io/topic';

class PostsScreen extends StatefulWidget {
  const PostsScreen({super.key});

  @override
  State<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> {
  List posts = [];
  bool isLoading = true;
  String errorMessage = '';
  String resultMessage = '';
  bool resultSuccess = true;
  String searchText = '';
  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchPosts();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // Posts that match the search text
  List get filteredPosts {
    if (searchText.isEmpty) {
      return posts;
    }
    return posts.where((p) {
      return p['title'].toString().toLowerCase().contains(
            searchText.toLowerCase(),
          );
    }).toList();
  }

  // GET request
    // GET request
  Future<void> fetchPosts({bool showLoader = true}) async {
    setState(() {
      if (showLoader) {
        isLoading = true;
      }
      errorMessage = '';
    });
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        setState(() {
          posts = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load posts. Code: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
        isLoading = false;
      });
    }
  }

  // POST request
  Future<void> sendPost(String title, String body) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'title': title, 'body': body}),
      );
      if (response.statusCode == 201) {
        setState(() {
          resultSuccess = true;
          resultMessage = 'Post created successfully!';
        });
        fetchPosts(showLoader: false); // show the new post in the list
      } else {
        setState(() {
          resultSuccess = false;
          resultMessage = 'Failed to create post. Code: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        resultSuccess = false;
        resultMessage = 'Failed to create post: $e';
      });
    }
  }

  // Dialog for the new post
  void showAddDialog() {
    final titleController = TextEditingController();
    final bodyController = TextEditingController();
    String dialogError = '';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: paperColor,
              title: const Text(
                'NEW POST',
                style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'Title'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: bodyController,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: 'Body'),
                  ),
                  if (dialogError.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        dialogError,
                        style: const TextStyle(color: rustColor),
                      ),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (titleController.text.trim().isEmpty ||
                        bodyController.text.trim().isEmpty) {
                      setDialogState(() {
                        dialogError = 'Title and body cannot be empty.';
                      });
                      return;
                    }
                    Navigator.pop(context);
                    sendPost(titleController.text, bodyController.text);
                  },
                  child: const Text('Send'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final box = Hive.box('favoritesBox');

    return Scaffold(
      appBar: AppBar(
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('LATEST NEWS', style: labelStyle(size: 9, color: softInk)),
            const Text(
              'POST READER',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        actions: [
          // Favorites button with a count badge
          ValueListenableBuilder(
            valueListenable: box.listenable(),
            builder: (context, Box b, _) {
              return IconButton(
                tooltip: 'Favorites',
                onPressed: () => Navigator.pushNamed(context, '/favorites'),
                icon: Badge(
                  isLabelVisible: b.length > 0,
                  label: Text('${b.length}'),
                  backgroundColor: rustColor,
                  child: const Icon(Icons.bookmark, color: rustColor),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: lineColor),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: showAddDialog,
        backgroundColor: rustColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.edit),
        label: const Text(
          'NEW POST',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5),
        ),
      ),
      body: Column(
        children: [
          buildSearchBar(),
          if (resultMessage.isNotEmpty)
            MessageBanner(text: resultMessage, success: resultSuccess),
          Expanded(child: buildBody()),
        ],
      ),
    );
  }

  Widget buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Container(
        decoration: BoxDecoration(
          color: cardPaper,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: lineColor),
        ),
        child: TextField(
          controller: searchController,
          onChanged: (value) {
            setState(() {
              searchText = value;
            });
          },
          decoration: InputDecoration(
            hintText: 'Search posts...',
            prefixIcon: const Icon(Icons.search, color: rustColor),
            suffixIcon: searchText.isEmpty
                ? null
                : IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      searchController.clear();
                      setState(() {
                        searchText = '';
                      });
                    },
                  ),
            filled: false,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }

  void openDetails(Map post) {
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

  // Big card for the first post
  Widget buildFeaturedCard(Map post) {
    return PaperCard(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 10),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      onTap: () => openDetails(post),
      child: Column(
        children: [
          const SectionLabel('FEATURED POST'),
          const SizedBox(height: 14),
          Text(
            post['title'].toString(),
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            post['body'].toString().replaceAll('\n', ' '),
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              fontStyle: FontStyle.italic,
              color: softInk,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'POST #${post['id']}  ·  READ MORE',
            style: labelStyle(size: 10, color: oliveColor),
          ),
        ],
      ),
    );
  }

  // Normal card for the other posts
  Widget buildPostCard(Map post) {
    return PaperCard(
      onTap: () => openDetails(post),
      child: Row(
        children: [
          Text(
            '${post['id']}',
            style: const TextStyle(
              color: rustColor,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post['title'].toString(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  post['body'].toString().replaceAll('\n', ' '),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: softInk),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: rustColor),
        ],
      ),
    );
  }

  Widget buildBody() {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: rustColor),
            SizedBox(height: 12),
            Text('Loading posts...'),
          ],
        ),
      );
    }
    if (errorMessage.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off, size: 60, color: rustColor),
              const SizedBox(height: 12),
              Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(color: rustColor),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => fetchPosts(),
                icon: const Icon(Icons.refresh),
                label: const Text('TRY AGAIN'),
              ),
            ],
          ),
        ),
      );
    }

    final list = filteredPosts;

    if (list.isEmpty) {
      return const Center(
        child: Text(
          'No posts found.',
          style: TextStyle(color: softInk, fontSize: 16),
        ),
      );
    }

    // Pull down to refresh
    return RefreshIndicator(
      color: rustColor,
      onRefresh: () => fetchPosts(showLoader: false),
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 90),
        itemCount: list.length,
        itemBuilder: (context, index) {
          final post = list[index] as Map;
          if (index == 0) {
            return buildFeaturedCard(post);
          }
          return buildPostCard(post);
        },
      ),
    );
  }
}