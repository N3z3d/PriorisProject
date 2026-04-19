// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:html' as html;

Uri? readCurrentBrowserUri() {
  return Uri.tryParse(html.window.location.href);
}

Future<void> persistBrowserSession({
  required String storageKey,
  required String serializedSession,
}) async {
  html.window.localStorage[storageKey] = serializedSession;
}

void replaceBrowserUrl(String url) {
  html.window.history.replaceState(null, '', url);
}
