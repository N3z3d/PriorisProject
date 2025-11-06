typedef ValidationRule<T> = String? Function(T entity);

class ValidationRuleSet<T> {
  ValidationRuleSet(this._rules);

  final List<ValidationRule<T>> _rules;

  List<String> evaluate(T entity) {
    final errors = <String>[];
    for (final rule in _rules) {
      final result = rule(entity);
      if (result != null) {
        errors.add(result);
      }
    }
    return errors;
  }
}
