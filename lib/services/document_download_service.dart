import 'package:dio/dio.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

class DocumentDownloadService {
  Future<void> openDocument(
    String url,
  ) async {
    final directory =
        await getApplicationDocumentsDirectory();

    String ext = '';
    try {
      final decodedPath = Uri.decodeComponent(Uri.parse(url).path);
      if (decodedPath.contains('.')) {
        ext = '.${decodedPath.split('.').last}';
      }
    } catch (e) {
      // ignore
    }

    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}$ext';

    final savePath =
        '${directory.path}/$fileName';

    await Dio().download(
      url,
      savePath,
    );

    await OpenFilex.open(savePath);
  }
}