import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/categories_service.dart';

final categoryServiceProvider = Provider<CategoryService>((ref) {
  return CategoryService();
});

final categoriesProvider = FutureProvider.autoDispose((ref) async {
  final service = ref.watch(categoryServiceProvider);
  return service.fetchCategories();
});
