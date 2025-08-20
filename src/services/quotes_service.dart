import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

class QuotesService {
  Future<String?> getDailyQuote() async {
    try {
      final String data = await rootBundle.loadString('assets/quotes.json');
      final List<dynamic> quotes = jsonDecode(data) as List<dynamic>;
      if (quotes.isEmpty) return null;
      final DateTime now = DateTime.now().toUtc();
      final int index = now.difference(DateTime.utc(2020, 1, 1)).inDays % quotes.length;
      return quotes[index] as String;
    } catch (_) {
      return null;
    }
  }
}
