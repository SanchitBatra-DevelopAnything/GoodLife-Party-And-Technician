import 'package:dio/dio.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

class DocumentDownloadService {
  Future<void> openDocument(
    String url,
  ) async {
    final directory =
        await getApplicationDocumentsDirectory();

    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}';

    final savePath =
        '${directory.path}/$fileName';

    await Dio().download(
      url,
      savePath,
    );

    await OpenFilex.open(savePath);
  }
}