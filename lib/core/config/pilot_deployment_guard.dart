/// Centralizes the Supabase hosts that must never back a public pilot build.
class PilotDeploymentGuard {
  PilotDeploymentGuard._();

  static const List<String> _placeholderSupabaseHostFragments = [
    'your-project-id.supabase.co',
    'your-project.supabase.co',
    'example.supabase.co',
    'project-id.supabase.co',
    'localhost',
    'test.supabase.co',
    'huxddyqkjczckagkpzef.supabase.co',
  ];

  static String? placeholderSupabaseHostFragment(String url) {
    final normalizedUrl = url.trim().toLowerCase();
    for (final fragment in _placeholderSupabaseHostFragments) {
      if (normalizedUrl.contains(fragment)) {
        return fragment;
      }
    }
    return null;
  }

  static bool usesPlaceholderSupabaseHost(String url) {
    return placeholderSupabaseHostFragment(url) != null;
  }
}
