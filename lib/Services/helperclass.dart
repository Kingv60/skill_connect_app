import 'dart:async';

import 'package:http/http.dart' as http;

class MultipartRequestWithProgress extends http.MultipartRequest {
  final Function(int bytes, int totalBytes) onProgress;

  MultipartRequestWithProgress(
      String method,
      Uri url, {
        required this.onProgress,
      }) : super(method, url);

  @override
  @override
  http.ByteStream finalize() {
    final byteStream = super.finalize();
    final total = contentLength;
    int bytesSent = 0;

    // Explicitly tell the transformer to expect List<int>
    final t = byteStream.transform(
      StreamTransformer<List<int>, List<int>>.fromHandlers(
        handleData: (List<int> data, EventSink<List<int>> sink) {
          bytesSent += data.length;
          onProgress(bytesSent, total);
          sink.add(data);
        },
      ),
    );
    return http.ByteStream(t);
  }
}