import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart' show rootBundle;

class QuotesService {
  List<String>? _cachedQuotes;
  final Random _random = Random();

  Future<List<String>> _loadQuotes() async {
    if (_cachedQuotes != null) return _cachedQuotes!;
    final String data = await rootBundle.loadString('assets/quotes.json');
    final List<dynamic> quotes = jsonDecode(data) as List<dynamic>;
    _cachedQuotes = quotes
        .map((dynamic e) => e.toString().trim())
        .where((String s) => s.isNotEmpty)
        .toList(growable: false);
    return _cachedQuotes!;
  }

  Future<String?> getDailyQuote() async {
    try {
      final List<String> quotes = await _loadQuotes();
      if (quotes.isEmpty) return null;
      final DateTime now = DateTime.now().toUtc();
      final int index = now.difference(DateTime.utc(2020, 1, 1)).inDays % quotes.length;
      return quotes[index];
    } catch (_) {
      return null;
    }
  }

  Future<String?> getRandomQuote({String? exclude}) async {
    try {
      final List<String> quotes = await _loadQuotes();
      if (quotes.isEmpty) return null;
      if (exclude != null && quotes.length > 1) {
        // Try a few times to avoid returning the same quote.
        for (int i = 0; i < 5; i++) {
          final String candidate = quotes[_random.nextInt(quotes.length)];
          if (candidate != exclude) return candidate;
        }
      }
      return quotes[_random.nextInt(quotes.length)];
    } catch (_) {
      return null;
    }
  }
}
