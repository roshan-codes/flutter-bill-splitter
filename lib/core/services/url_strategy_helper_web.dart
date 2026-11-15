// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:html' as html;

/// Web implementation: clears story_id query parameter from the browser's address bar without reloading.
void clearWebUrlQuery() {
  try {
    final uri = Uri.base;
    if (uri.queryParameters.containsKey('story_id')) {
      final newParams = Map<String, String>.from(uri.queryParameters)
        ..remove('story_id');
      final newUri = uri.replace(
        queryParameters: newParams.isEmpty ? null : newParams,
      );
      html.window.history.replaceState(null, '', newUri.toString());
    }
  } catch (_) {}
}
