class Category {
  final String id;
  final String name;
  final String icon;
  final List<String> words;

  const Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.words,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    final rawWords = json['words'];
    final words = rawWords is List
        ? rawWords.whereType<String>().toList()
        : <String>[];
    return Category(
      id: (json['id'] ?? '') as String,
      name: (json['name'] ?? '') as String,
      icon: (json['icon'] ?? '❓') as String,
      words: words,
    );
  }
}
