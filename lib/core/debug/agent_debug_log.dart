import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// Gửi log debug tới ingest (Android emulator: 10.0.2.2 = máy host).
// #region agent log
void agentDebugLog(
  String location,
  String message,
  Map<String, Object?> data, {
  String hypothesisId = '?',
  String runId = 'pre-fix',
}) {
  scheduleMicrotask(() async {
    try {
      final uri = Uri.parse(Platform.isAndroid
          ? 'http://10.0.2.2:7248/ingest/29dfe097-f1db-443e-81c3-4c42ecf5cb20'
          : 'http://127.0.0.1:7248/ingest/29dfe097-f1db-443e-81c3-4c42ecf5cb20');
      final payload = jsonEncode({
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'location': location,
        'message': message,
        'data': data,
        'hypothesisId': hypothesisId,
        'runId': runId,
      });
      final client = HttpClient();
      final req = await client.postUrl(uri);
      req.headers.contentType = ContentType.json;
      req.write(payload);
      await req.close();
      client.close(force: true);
    } catch (_) {}
  });
}
// #endregion
