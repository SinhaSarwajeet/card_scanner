import 'package:shared_preferences/shared_preferences.dart';
import '../model/card_detail_model.dart';
import 'dart:convert';

class SharedPreferencesService {
  Future<void> saveCards(List<CardDetails> cards) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> jsonCards = cards.map((card) => jsonEncode(card.toJson())).toList();
    prefs.setStringList('cardDetails', jsonCards);
  }

  Future<List<CardDetails>> loadCards() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? jsonCards = prefs.getStringList('cardDetails');
    if (jsonCards != null) {
      return jsonCards.map((jsonCard) => CardDetails.fromJson(jsonDecode(jsonCard))).toList();
    }
    return [];
  }
}
