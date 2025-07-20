import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/sadaka_item.dart';

class SadakaProvider with ChangeNotifier {
  List<SadakaItem> _items = [];
  final String _storageKey = 'sadaka_items';
  final String _selectedMonthKey = 'selected_month';
  final String _selectedYearKey = 'selected_year';

  List<SadakaItem> get items => [..._items];

  // Get items for a specific date
  List<SadakaItem> getItemsForDate(DateTime date) {
    return _items
        .where(
          (item) =>
              item.date.year == date.year &&
              item.date.month == date.month &&
              item.date.day == date.day,
        )
        .toList();
  }

  // Get total amount for a specific month
  double getMonthTotal(int month, int year) {
    return _items
        .where((item) => item.date.month == month && item.date.year == year)
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  // Get total amount for a specific year
  double getYearTotal(int year) {
    return _items
        .where((item) => item.date.year == year)
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  // Get paid amount for a specific month
  double getMonthPaidAmount(int month, int year) {
    return _items
        .where((item) => item.date.month == month && item.date.year == year)
        .fold(0.0, (sum, item) => sum + item.paidAmount);
  }

  // Get paid amount for a specific year
  double getYearPaidAmount(int year) {
    return _items
        .where((item) => item.date.year == year)
        .fold(0.0, (sum, item) => sum + item.paidAmount);
  }

  // Check if month is fully paid
  bool isMonthFullyPaid(int month, int year) {
    final monthTotal = getMonthTotal(month, year);
    final paidAmount = getMonthPaidAmount(month, year);

    // If there are no items for this month, consider it fully paid
    if (monthTotal == 0) return true;

    // Check if all items are fully paid
    return paidAmount >= monthTotal;
  }

  // Add a new item
  void addItem(SadakaItem item) {
    _items.add(item);
    _saveItems();
    notifyListeners();
  }

  // Update an existing item
  void updateItem(String id, String title, double amount) {
    final itemIndex = _items.indexWhere((item) => item.id == id);
    if (itemIndex >= 0) {
      _items[itemIndex].title = title;
      _items[itemIndex].amount = amount;
      _saveItems();
      notifyListeners();
    }
  }

  // Delete an item
  void deleteItem(String id) {
    _items.removeWhere((item) => item.id == id);
    _saveItems();
    notifyListeners();
  }

  // Make a payment for a month
  void makePayment(int month, int year, double amount) {
    double total = getMonthTotal(month, year);
    double currentPaid = getMonthPaidAmount(month, year);

    // Don't allow overpayment
    if (currentPaid + amount > total) {
      amount = total - currentPaid;
    }

    if (amount <= 0) return;

    // Distribute payment proportionally among items
    List<SadakaItem> monthItems =
        _items
            .where((item) => item.date.month == month && item.date.year == year)
            .toList();

    if (monthItems.isEmpty) return;

    for (var item in monthItems) {
      double proportion = item.amount / total;
      double itemPayment = amount * proportion;
      item.paidAmount += itemPayment;

      // Mark as paid if fully paid
      if (item.paidAmount >= item.amount) {
        item.isPaid = true;
      }
    }

    _saveItems();
    notifyListeners();
  }

  // Make full payment for a month
  void makeFullPayment(int month, int year) {
    List<SadakaItem> monthItems =
        _items
            .where((item) => item.date.month == month && item.date.year == year)
            .toList();

    for (var item in monthItems) {
      item.paidAmount = item.amount;
      item.isPaid = true;
    }

    _saveItems();
    notifyListeners();
  }

  // Load items from storage
  Future<void> loadItems() async {
    final prefs = await SharedPreferences.getInstance();
    final itemsJson = prefs.getString(_storageKey);

    if (itemsJson != null) {
      final List<dynamic> decodedItems = json.decode(itemsJson);
      _items = decodedItems.map((item) => SadakaItem.fromJson(item)).toList();
      notifyListeners();
    }
  }

  // Save items to storage
  Future<void> _saveItems() async {
    final prefs = await SharedPreferences.getInstance();
    final itemsJson = json.encode(_items.map((item) => item.toJson()).toList());
    await prefs.setString(_storageKey, itemsJson);
  }

  // Save selected month and year
  Future<void> saveSelectedMonth(int month, int year) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_selectedMonthKey, month);
    await prefs.setInt(_selectedYearKey, year);
  }

  // Get selected month
  Future<int> getSelectedMonth() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_selectedMonthKey) ?? DateTime.now().month;
  }

  // Get selected year
  Future<int> getSelectedYear() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_selectedYearKey) ?? DateTime.now().year;
  }
}
