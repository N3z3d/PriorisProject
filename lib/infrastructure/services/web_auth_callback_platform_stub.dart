Uri? readCurrentBrowserUri() => null;

String? readBrowserStorageItem(String key) => null;

Future<void> persistBrowserSession({
  required String storageKey,
  required String serializedSession,
}) async {}

void replaceBrowserUrl(String url) {}
