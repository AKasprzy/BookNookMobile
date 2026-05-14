import 'package:flutter/material.dart';
import '../services/api_service.dart';

class CreateBookScreen extends StatefulWidget {
  const CreateBookScreen({super.key});

  @override
  State<CreateBookScreen> createState() => _CreateBookScreenState();
}

class _CreateBookScreenState extends State<CreateBookScreen> {
  final api = ApiService();

  final title = TextEditingController();
  final author = TextEditingController();
  final originalLanguage = TextEditingController();
  final publicationDate = TextEditingController();
  final series = TextEditingController();

  final editionTitle = TextEditingController();
  final editionLanguage = TextEditingController();
  final publisher = TextEditingController();
  final editionDate = TextEditingController();
  final isbn = TextEditingController();
  final pages = TextEditingController();
  final length = TextEditingController();
  final coverUrl = TextEditingController();
  final description = TextEditingController();

  String? format;

  bool loading = false;

  Future<void> submit() async {
    if (format == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Select a format")),
      );
      return;
    }

    setState(() => loading = true);

    try {
      await api.post("books", {
        "title": title.text.trim(),
        "author": author.text.trim(),
        "original_language": originalLanguage.text.trim(),
        "original_publication_date":
        publicationDate.text.trim().isEmpty
            ? null
            : publicationDate.text.trim(),
        "series":
        series.text.trim().isEmpty
            ? null
            : series.text.trim(),
        "genre_ids": [],
        "motif_ids": [],
        "edition": {
          "edition_title": editionTitle.text.trim(),
          "edition_language": editionLanguage.text.trim(),
          "publisher":
          publisher.text.trim().isEmpty
              ? null
              : publisher.text.trim(),
          "edition_publication_date":
          editionDate.text.trim().isEmpty
              ? null
              : editionDate.text.trim(),
          "isbn":
          isbn.text.trim().isEmpty
              ? null
              : isbn.text.trim(),
          "page_count":
          pages.text.trim().isEmpty
              ? null
              : int.parse(pages.text.trim()),
          "length_minutes":
          length.text.trim().isEmpty
              ? null
              : int.parse(length.text.trim()),
          "cover_url":
          coverUrl.text.trim().isEmpty
              ? null
              : coverUrl.text.trim(),
          "description":
          description.text.trim().isEmpty
              ? null
              : description.text.trim(),
          "format": format,
        }
      });

      if (!mounted) return;

      Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }

    if (mounted) {
      setState(() => loading = false);
    }
  }

  Widget input(
      String label,
      TextEditingController c, {
        TextInputType? type,
        bool required = false,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: const TextStyle(
              color: Colors.black,
              fontSize: 14,
            ),
            children: [
              TextSpan(
                text: label,
                style: TextStyle(
                  fontWeight:
                  required ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              if (required)
                const TextSpan(
                  text: " *",
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: c,
          keyboardType: type,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: ListView(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 60, 16, 30),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0F172A),
                  Color(0xFF1E293B),
                  Color(0xFF0F172A),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Add New Book",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  "Create a new book entry",
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                section("Book Information", [
                  input(
                    "Title",
                    title,
                    required: true,
                  ),
                  input(
                    "Author",
                    author,
                    required: true,
                  ),
                  input(
                    "Original Language",
                    originalLanguage,
                    required: true,
                  ),
                  input(
                    "Publication Date",
                    publicationDate,
                  ),
                  input(
                    "Series",
                    series,
                  ),
                ]),
                section("Edition Information", [
                  input(
                    "Edition Title",
                    editionTitle,
                    required: true,
                  ),
                  dropdown(),
                  input(
                    "Edition Language",
                    editionLanguage,
                    required: true,
                  ),
                  input(
                    "Publisher",
                    publisher,
                  ),
                  input(
                    "Edition Date",
                    editionDate,
                  ),
                  input(
                    "ISBN",
                    isbn,
                  ),
                  input(
                    "Page Count",
                    pages,
                    type: TextInputType.number,
                  ),
                  input(
                    "Length (minutes)",
                    length,
                    type: TextInputType.number,
                  ),
                  input(
                    "Cover URL",
                    coverUrl,
                  ),
                  input(
                    "Description",
                    description,
                  ),
                ]),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: loading ? null : submit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                  ),
                  child: Text(
                    loading ? "Creating..." : "Create Book",
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget section(String title, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...children.map(
                (w) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: w,
            ),
          )
        ],
      ),
    );
  }

  Widget dropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: const TextSpan(
            style: TextStyle(
              color: Colors.black,
              fontSize: 14,
            ),
            children: [
              TextSpan(
                text: "Format",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                text: " *",
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: format,
          items: const [
            DropdownMenuItem(
              value: "print",
              child: Text("Print"),
            ),
            DropdownMenuItem(
              value: "digital",
              child: Text("E-book"),
            ),
            DropdownMenuItem(
              value: "audio",
              child: Text("Audiobook"),
            ),
          ],
          onChanged: (v) => setState(() => format = v),
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }
}