import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/dashboard_section.dart';

class DashboardProvider with ChangeNotifier {
  List<DashboardSection> _sections = DashboardSectionType.getDefaultSections();

  List<DashboardSection> get sections => _sections;

  DashboardProvider() {
    _loadSectionOrder();
  }

  Future<void> _loadSectionOrder() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? sectionsJson = prefs.getString('dashboard_sections');

      if (sectionsJson != null) {
        final List<dynamic> decoded = jsonDecode(sectionsJson);
        _sections = decoded
            .map((json) => DashboardSection.fromJson(json))
            .toList();
        _sections.sort((a, b) => a.order.compareTo(b.order));
        notifyListeners();
      }
    } catch (e) {
      print('Error loading section order: $e');
    }
  }

  Future<void> reorderSections(int oldIndex, int newIndex) async {
    final section = _sections.removeAt(oldIndex);
    _sections.insert(newIndex, section);

    // Update order values
    for (int i = 0; i < _sections.length; i++) {
      _sections[i].order = i;
    }

    notifyListeners();
    await _saveSectionOrder();
  }

  Future<void> _saveSectionOrder() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encoded = jsonEncode(
        _sections.map((s) => s.toJson()).toList(),
      );
      await prefs.setString('dashboard_sections', encoded);
    } catch (e) {
      print('Error saving section order: $e');
    }
  }

  Future<void> resetToDefault() async {
    _sections = DashboardSectionType.getDefaultSections();
    notifyListeners();
    await _saveSectionOrder();
  }
}
