import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Available sort options
enum SortOption { dueDate, priority }

// StateNotifier to store the current sorting option
class SortOptionNotifier extends StateNotifier<SortOption> {
  SortOptionNotifier() : super(SortOption.dueDate) {
    _loadPreference();
  }

  Future<void> _loadPreference() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString('sortOption') ?? 'dueDate';
    state = value == 'priority' ? SortOption.priority : SortOption.dueDate;
  }

  Future<void> setSortOption(SortOption option) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('sortOption', option.name);
    state = option;
  }
}

// Global Riverpod provider
final sortOptionProvider =
StateNotifierProvider<SortOptionNotifier, SortOption>((ref) {
  return SortOptionNotifier();
});
