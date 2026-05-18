import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ScriptureSelectorPage extends StatelessWidget {
  const ScriptureSelectorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Verse'), backgroundColor: Colors.teal),
      body: const Books(isSelectorMode: true),
    );
  }
}

class Books extends StatefulWidget {
  final bool isSelectorMode;
  const Books({super.key, this.isSelectorMode = false});

  @override
  State<Books> createState() => _BooksState();
}

class _BooksState extends State<Books> {
  final List<int> chapters = [];
  final List<int> versesList = [];
  List<dynamic> apiBooks = [];

  final translation = 'BSB';
  String? selectedBook;
  int? selectedBookChapter;
  int? selectedVerse;

  int numberOfVerse = 0;
  List<dynamic> chapterData = [];

  Future<void> getBooks() async {
    try {
      final response = await http.get(Uri.parse('https://bible.helloao.org/api/$translation/books.json'));
      if (response.statusCode == 200) {
        final bibleData = json.decode(response.body);
        apiBooks = bibleData['books'] ?? [];

        setState(() {
          if (apiBooks.isNotEmpty) {
            selectedBook = apiBooks.first['id'];
            updateChaptersForSelectedBook();
          }
        });
      }
    } catch (e) {
      print("Error fetching books: $e");
    }
  }

  void updateChaptersForSelectedBook() {
    if (selectedBook == null || apiBooks.isEmpty) return;

    setState(() {
      chapters.clear();
      versesList.clear();
      selectedVerse = null;
      chapterData = [];
      numberOfVerse = 0;
    });

    dynamic matchedBook;
    for (var b in apiBooks) {
      if (b['id'] == selectedBook) {
        matchedBook = b;
        break;
      }
    }
    if (matchedBook == null) return;

    int totalChapters = matchedBook['numberOfChapters'];
    setState(() {
      for (int chapter = 1; chapter <= totalChapters; chapter++) {
        chapters.add(chapter);
      }
      selectedBookChapter = chapters.first;
    });

    getChapters();
  }

  Future<void> getChapters() async {
    if (selectedBook == null || selectedBookChapter == null) return;
    try {
      final response = await http.get(Uri.parse('https://bible.helloao.org/api/$translation/$selectedBook/$selectedBookChapter.json'));
      if (response.statusCode == 200) {
        final verseData = json.decode(response.body);
        setState(() {
          numberOfVerse = verseData['numberOfVerses'] ?? 0;
          chapterData = verseData['chapter']['content'] ?? [];

          versesList.clear();
          for (int i = 1; i <= numberOfVerse; i++) {
            versesList.add(i);
          }

          if (versesList.isNotEmpty) {
            selectedVerse = versesList.first;
          }
        });
      }
    } catch (e) {
      print("Error fetching chapters: $e");
    }
  }

  String getSelectedBookName() {
    if (selectedBook == null || apiBooks.isEmpty) return '';
    for (var book in apiBooks) {
      if (book['id'] == selectedBook) {
        return book['name'];
      }
    }
    return '';
  }

  String getVerse(int verse) {
    for (var item in chapterData) {
      if (item['type'] == 'verse' && item['number'] == verse) {
        return item['content'].whereType<String>().join();
      }
    }
    return '';
  }

  @override
  void initState() {
    super.initState();
    getBooks();
  }

  @override
  Widget build(BuildContext context) {
    if (apiBooks.isEmpty) return const Center(child: CircularProgressIndicator());

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          DropdownButton<String>(
            isExpanded: true,
            value: selectedBook,
            items: apiBooks.map((b) => DropdownMenuItem(value: b['id'] as String, child: Text(b['name']))).toList(),
            onChanged: (val) => setState(() { selectedBook = val; updateChaptersForSelectedBook(); }),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              DropdownButton<int>(
                value: selectedBookChapter,
                items: chapters.map((c) => DropdownMenuItem(value: c, child: Text("Chapter $c"))).toList(),
                onChanged: (val) => setState(() { selectedBookChapter = val; getChapters(); }),
              ),
              DropdownButton<int>(
                value: selectedVerse,
                items: versesList.map((v) => DropdownMenuItem(value: v, child: Text("Verse $v"))).toList(),
                onChanged: (val) => setState(() { selectedVerse = val; }),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              child: Text(
                getVerse(selectedVerse ?? 1),
                style: const TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
              ),
            ),
          ),
          if (widget.isSelectorMode && selectedVerse != null)
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
              onPressed: () => Navigator.pop(context, {
                'text': getVerse(selectedVerse!),
                'reference': '${getSelectedBookName()} $selectedBookChapter:$selectedVerse',
              }),
              child: const Text("Select Verse", style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
    );
  }
}
