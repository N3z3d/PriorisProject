import 'dart:io';

import 'package:prioris/core/config/pilot_deployment_guard.dart';

void main() {
  final supabaseUrl = _requireEnvironmentVariable('PILOT_SUPABASE_URL');
  final parsedUrl = Uri.tryParse(supabaseUrl);

  if (parsedUrl == null ||
      !parsedUrl.isAbsolute ||
      parsedUrl.scheme != 'https' ||
      !parsedUrl.host.endsWith('supabase.co')) {
    stderr.writeln(
      'PILOT_SUPABASE_URL must be a valid https Supabase host. Got: $supabaseUrl',
    );
    exit(1);
  }

  final blockedHost =
      PilotDeploymentGuard.placeholderSupabaseHostFragment(supabaseUrl);
  if (blockedHost != null) {
    stderr.writeln(
      'PILOT_SUPABASE_URL points to a placeholder or dead Supabase host '
      'that cannot back the public pilot: $blockedHost',
    );
    exit(1);
  }

  stdout.writeln('Pilot Pages configuration is valid for $supabaseUrl');
}

String _requireEnvironmentVariable(String key) {
  final value = Platform.environment[key]?.trim() ?? '';
  if (value.isEmpty) {
    stderr.writeln('Missing required environment variable: $key');
    exit(1);
  }
  return value;
}
