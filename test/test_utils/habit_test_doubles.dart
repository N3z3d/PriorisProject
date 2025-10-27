import 'package:flutter/material.dart';
import 'package:prioris/presentation/pages/habits/services/habit_category_service.dart';

class HabitCategoryServiceSpy extends HabitCategoryService {
  HabitCategoryServiceSpy({
    this.createdValue,
  });

  final String? createdValue;
  int promptInvocationCount = 0;

  @override
  Future<String?> promptCreateCategory(BuildContext context) async {
    promptInvocationCount += 1;
    return createdValue;
  }
}
