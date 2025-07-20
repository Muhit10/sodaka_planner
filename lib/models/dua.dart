import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';

class Dua {
  final String arabic;
  final String bangla;
  
  Dua({required this.arabic, required this.bangla});
  
  factory Dua.fromJson(Map<String, dynamic> json) => 
    Dua(
      arabic: json['arabic'] as String, 
      bangla: json['bangla'] as String
    );

  static Future<List<Dua>> loadDuas() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/dua_list.json');
      final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
      return jsonList.map((e) => Dua.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      // Return an empty list if there's an error loading the file
      return [];
    }
  }

  static Dua getRandomDua(List<Dua> duas) {
    if (duas.isEmpty) {
      // Return a default dua if the list is empty
      return Dua(
        arabic: 'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ',
        bangla: 'শুরু করছি আল্লাহর নামে যিনি পরম করুণাময়, অতি দয়ালু।'
      );
    }
    
    final random = Random();
    return duas[random.nextInt(duas.length)];
  }
}