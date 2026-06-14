import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage storage = FirebaseStorage.instance;

  Future<String> uploadImageWithProgress(
    File file,
    Function(double) onProgress,
  ) async {
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';

    final Reference ref = storage
        .ref()
        .child('distributor_images')
        .child(fileName);

    final UploadTask uploadTask = ref.putFile(
      file,
      SettableMetadata(contentType: 'image/jpeg'),
    );

    uploadTask.snapshotEvents.listen((snapshot) {
      final progress =
          snapshot.bytesTransferred / snapshot.totalBytes;

      onProgress(progress);
    });

    final TaskSnapshot snapshot = await uploadTask;

    if (snapshot.state == TaskState.success) {
      return await snapshot.ref.getDownloadURL();
    } else {
      throw Exception('Upload failed');
    }
  }


  Future<String> uploadCustomOrderImageWithProgress(
  File file,
  Function(double) onProgress,
) async {
  final now = DateTime.now();

  final fileName =
      '${now.millisecondsSinceEpoch}.jpg';

  final Reference ref = storage
      .ref()
      .child('custom_order')
      .child('${now.year}')
      .child(now.month.toString().padLeft(2, '0'))
      .child(now.day.toString().padLeft(2, '0'))
      .child(fileName);

  final UploadTask uploadTask = ref.putFile(
    file,
    SettableMetadata(contentType: 'image/jpeg'),
  );

  uploadTask.snapshotEvents.listen((snapshot) {
    final progress =
        snapshot.bytesTransferred / snapshot.totalBytes;

    onProgress(progress);
  });

  final TaskSnapshot snapshot = await uploadTask;

  if (snapshot.state == TaskState.success) {
    return await snapshot.ref.getDownloadURL();
  } else {
    throw Exception('Upload failed');
  }
}


}