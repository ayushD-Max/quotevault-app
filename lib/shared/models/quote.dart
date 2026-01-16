class Quote {
  final int id;
  final String text;
  final String author;
  final String category;
  final bool liked;

  const Quote({
    required this.id,
    required this.text,
    required this.author,
    required this.category,
    this.liked = false,
  });

  Quote copyWith({bool? liked}) => Quote(
        id: id,
        text: text,
        author: author,
        category: category,
        liked: liked ?? this.liked,
      );
}