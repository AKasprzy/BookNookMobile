import 'package:flutter/material.dart';
import '../services/api_service.dart';

class EditionsScreen extends StatefulWidget {
  final int bookId;

  const EditionsScreen({
    super.key,
    required this.bookId,
  });

  @override
  State<EditionsScreen> createState() => _EditionsScreenState();
}

class _EditionsScreenState extends State<EditionsScreen> {
  final api = ApiService();

  bool loading = true;

  List editions = [];

  @override
  void initState() {
    super.initState();
    loadEditions();
  }

  Future<void> loadEditions() async {
    try {
      final res = await api.get("books/${widget.bookId}");

      setState(() {
        editions = res['data']['editions'] ?? [];
        loading = false;
      });
    } catch (_) {
      setState(() {
        loading = false;
      });
    }
  }

  void openEdition(int id) {
    Navigator.pushNamed(
      context,
      '/book',
      arguments: {
        'bookId': widget.bookId,
        'editionId': id,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: loading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(
              16,
              60,
              16,
              32,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0F172A),
                  Color(0xFF1E293B),
                  Color(0xFF0F172A),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        "← Back",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          '/book-editions/create',
                          arguments: widget.bookId,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                      ),
                      child: const Text("Add Edition"),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  "Browse Editions",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: RefreshIndicator(
              onRefresh: loadEditions,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (editions.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 40),
                      child: Center(
                        child: Text(
                          "No editions found",
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),

                  ...editions.map((edition) {
                    return GestureDetector(
                      onTap: () =>
                          openEdition(edition['id']),
                      child: Container(
                        margin:
                        const EdgeInsets.only(
                            bottom: 16),
                        padding:
                        const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                          BorderRadius.circular(
                              16),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 10,
                              offset:
                              Offset(0, 4),
                            )
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 90,
                              height: 130,
                              decoration:
                              BoxDecoration(
                                color: Colors
                                    .grey.shade300,
                                borderRadius:
                                BorderRadius
                                    .circular(12),
                              ),
                              clipBehavior:
                              Clip.antiAlias,
                              child: edition[
                              'cover_url'] !=
                                  null
                                  ? Image.network(
                                edition[
                                'cover_url'],
                                fit: BoxFit
                                    .cover,
                              )
                                  : const Icon(
                                Icons.menu_book,
                                color:
                                Colors.grey,
                                size: 40,
                              ),
                            ),

                            const SizedBox(width: 16),

                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                                children: [
                                  Text(
                                    edition[
                                    'edition_title'] ??
                                        edition[
                                        'book']
                                        ['title'],
                                    style:
                                    const TextStyle(
                                      fontSize: 18,
                                      fontWeight:
                                      FontWeight
                                          .bold,
                                    ),
                                  ),

                                  const SizedBox(
                                      height: 6),

                                  Text(
                                    edition['book']
                                    ['author'],
                                    style:
                                    const TextStyle(
                                      color:
                                      Colors.grey,
                                    ),
                                  ),

                                  const SizedBox(
                                      height: 12),

                                  Wrap(
                                    spacing: 12,
                                    runSpacing: 8,
                                    children: [
                                      if (edition[
                                      'edition_language'] !=
                                          null)
                                        Text(
                                          edition[
                                          'edition_language'],
                                          style:
                                          const TextStyle(
                                            fontSize:
                                            13,
                                            color: Colors
                                                .black54,
                                          ),
                                        ),

                                      if (edition[
                                      'format'] !=
                                          null)
                                        Text(
                                          edition[
                                          'format'],
                                          style:
                                          const TextStyle(
                                            fontSize:
                                            13,
                                            color: Colors
                                                .black54,
                                          ),
                                        ),

                                      if (edition[
                                      'publisher'] !=
                                          null)
                                        Text(
                                          edition[
                                          'publisher'],
                                          style:
                                          const TextStyle(
                                            fontSize:
                                            13,
                                            color: Colors
                                                .black54,
                                          ),
                                        ),

                                      if (edition[
                                      'edition_publication_date'] !=
                                          null)
                                        Text(
                                          edition[
                                          'edition_publication_date'],
                                          style:
                                          const TextStyle(
                                            fontSize:
                                            13,
                                            color: Colors
                                                .black54,
                                          ),
                                        ),
                                    ],
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  })
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}