/// Types d'actions de swipe
enum SwipeActionType {
  delete,
  complete,
  edit,
  archive,
}

/// Contextes haptiques
enum HapticContext {
  buttonPress,
  listScroll,
  tabSwitch,
  formValidation,
  gameAction,
}

/// Intensité du feedback haptique
enum HapticIntensity {
  light,
  medium,
  heavy,
}
