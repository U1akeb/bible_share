import 'package:flutter/material.dart';
import 'package:bible_share/get/get_books.dart';
import 'package:bible_share/get/crud_api.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ReflectionPost> posts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    setState(() {
      isLoading = true;
    });
    try {
      final fetchedPosts = await CrudApi.fetchReflections();
      setState(() {
        posts = fetchedPosts;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error loading posts: $e")));
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void showPostForm({ReflectionPost? existingPost}) {
    final title = TextEditingController(
      text: existingPost != null ? existingPost.title : "",
    );
    final reflection = TextEditingController(
      text: existingPost != null ? existingPost.reflection : "",
    );
    String? vText = existingPost?.verseText;
    String? vRef = existingPost?.verseReference;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(
            existingPost == null ? "New Reflection" : "Edit Reflection",
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: title,
                  decoration: const InputDecoration(labelText: "Title"),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    final res = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ScriptureSelectorPage(),
                      ),
                    );
                    if (res != null) {
                      setDialogState(() {
                        vText = res['text'];
                        vRef = res['reference'];
                      });
                    }
                  },
                  child: Text(vText == null ? "Select Scripture Text" : vRef!),
                ),
                if (vText != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      '"$vText"',
                      style: const TextStyle(
                        fontStyle: FontStyle.italic,
                        fontSize: 12,
                      ),
                    ),
                  ),
                TextField(
                  controller: reflection,
                  decoration: const InputDecoration(
                    labelText: "Your Reflection",
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
              onPressed: () async {
                if (title.text.isNotEmpty &&
                    reflection.text.isNotEmpty &&
                    vText != null) {
                  Navigator.pop(
                    ctx,
                  );

                  setState(() {
                    isLoading = true;
                  });

                  try {
                    if (existingPost == null) {
                      final newPost = ReflectionPost(
                        title: title.text,
                        verseText: vText!,
                        verseReference: vRef!,
                        reflection: reflection.text,
                      );
                      await CrudApi.createReflection(newPost);
                    } else {
                      final updatedPost = ReflectionPost(
                        id: existingPost.id,
                        title: title.text,
                        verseText: vText!,
                        verseReference: vRef!,
                        reflection: reflection.text,
                      );
                      await CrudApi.updateReflection(updatedPost);
                    }
                    await _loadPosts();
                  } catch (e) {
                    setState(() {
                      isLoading = false;
                    });
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Error saving: $e")),
                      );
                    }
                  }
                }
              },
              child: Text(
                existingPost == null ? "Post" : "Save",
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Reflections"),
        backgroundColor: Colors.teal,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.teal))
          : posts.isEmpty
          ? const Center(child: Text("No reflections yet. Add one!"))
          : ListView.builder(
              itemCount: posts.length,
              itemBuilder: (ctx, i) {
                final p = posts[i];
                return Card(
                  margin: const EdgeInsets.all(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              p.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.teal,
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit_outlined,
                                    color: Colors.teal,
                                  ),
                                  onPressed: () => showPostForm(
                                    existingPost: p,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.redAccent,
                                  ),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: const Text("Delete Reflection?"),
                                        content: const Text(
                                          "Are you sure you want to delete this reflection?",
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(ctx),
                                            child: const Text("Cancel"),
                                          ),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.redAccent,
                                            ),
                                            onPressed: () async {
                                              Navigator.pop(
                                                ctx,
                                              );
                                              setState(() {
                                                isLoading = true;
                                              });
                                              try {
                                                await CrudApi.deleteReflection(
                                                  p.id!,
                                                );
                                                await _loadPosts();
                                              } catch (e) {
                                                setState(() {
                                                  isLoading = false;
                                                });
                                                if (mounted) {
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        "Error deleting: $e",
                                                      ),
                                                    ),
                                                  );
                                                }
                                              }
                                            },
                                            child: const Text(
                                              "Delete",
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          color: Colors.teal.shade50.withOpacity(0.3),
                          padding: const EdgeInsets.all(8),
                          child: Text(
                            '"${p.verseText}"\n- ${p.verseReference}',
                            style: const TextStyle(fontStyle: FontStyle.italic),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(p.reflection),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showPostForm(),
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
