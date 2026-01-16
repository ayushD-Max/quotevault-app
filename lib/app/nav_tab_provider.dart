import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
/// 0=Home, 1=Search, 2=Favorites, 3=Profile
final currentTabProvider = StateProvider<int>((ref) => 0);