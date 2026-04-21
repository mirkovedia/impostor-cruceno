import 'dart:convert';
import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter/services.dart';
import '../models/category.dart';

class WordsRepository {
  List<Category>? _cachedCategories;

  Future<List<Category>> loadCategories() async {
    if (_cachedCategories != null) return _cachedCategories!;

    debugPrint('[WordsRepository] Cargando words.json...');
    final jsonString = await rootBundle.loadString('assets/data/words.json');
    debugPrint('[WordsRepository] JSON leído: ${jsonString.length} caracteres');
    final jsonList = json.decode(jsonString) as List<dynamic>;
    _cachedCategories = jsonList
        .map((e) => Category.fromJson(e as Map<String, dynamic>))
        .toList();
    debugPrint('[WordsRepository] ${_cachedCategories!.length} categorías parseadas');
    return _cachedCategories!;
  }
}
