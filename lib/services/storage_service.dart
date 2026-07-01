import 'dart:io';
import 'dart:typed_data';
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

Future<String> uploadPurchaseOrder({
  required String firebaseOrderId,
  required Uint8List pdfBytes,
  required String fileName,
}) async {
  final ref = FirebaseStorage.instance
      .ref()
      .child('purchase_orders')
      .child(firebaseOrderId)
      .child(fileName);

  await ref.putData(
    pdfBytes,
    SettableMetadata(
      contentType: 'application/pdf',
    ),
  );

  return await ref.getDownloadURL();
}

  Future<String> uploadServiceRequestMedia({
    required File file,
    required String fileType,
    required String extension,
    required Function(double) onProgress,
  }) async {
    final now = DateTime.now();
    final fileName = '${now.millisecondsSinceEpoch}_$fileType.$extension';

    final Reference ref = storage
        .ref()
        .child('service_requests')
        .child('${now.year}')
        .child(now.month.toString().padLeft(2, '0'))
        .child(fileName);

    String contentType = 'application/octet-stream';
    if (fileType == 'image') {
      contentType = 'image/jpeg';
    } else if (fileType == 'video') {
      contentType = 'video/mp4';
    } else if (fileType == 'audio') {
      if (extension == 'mp3') {
        contentType = 'audio/mpeg';
      } else if (extension == 'wav') {
        contentType = 'audio/wav';
      } else if (extension == 'm4a') {
        contentType = 'audio/x-m4a';
      } else {
        contentType = 'audio/$extension';
      }
    }

    final UploadTask uploadTask = ref.putFile(
      file,
      SettableMetadata(contentType: contentType),
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