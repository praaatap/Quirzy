import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

class ImageState {
  final Uint8List? imageBytes;
  final String? imageName;

  ImageState({this.imageBytes, this.imageName});

  ImageState copyWith({Uint8List? imageBytes, String? imageName}) {
    return ImageState(
      imageBytes: imageBytes ?? this.imageBytes,
      imageName: imageName ?? this.imageName,
    );
  }
}

class ImageNotifier extends StateNotifier<ImageState> {
  ImageNotifier() : super(ImageState());

  Future<void> pickImage() async {
    try {
      if (kIsWeb) {
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.image,
          allowMultiple: false,
        );
        if (result != null) {
          state = state.copyWith(
            imageBytes: result.files.first.bytes,
            imageName: result.files.first.name,
          );
        }
      } else {
        final picker = ImagePicker();
        final pickedFile = await picker.pickImage(source: ImageSource.gallery);
        if (pickedFile != null) {
          final bytes = await pickedFile.readAsBytes();
          state = state.copyWith(
            imageBytes: bytes,
            imageName: pickedFile.name,
          );
        }
      }
    } catch (e) {
      throw Exception("Error picking image: ${e.toString()}");
    }
  }

  void clearImage() {
    state = ImageState();
  }
}

final imageProvider = StateNotifierProvider<ImageNotifier, ImageState>((ref) {
  return ImageNotifier();
});