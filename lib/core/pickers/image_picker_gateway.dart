import 'package:image_picker/image_picker.dart';

/// Injectable abstraction over gallery image picking.
///
/// Owned by the MutationBloc; UI only dispatches pick events.
abstract class ImagePickerGateway {
  Future<List<String>> pickImagePaths();
}

class GalleryImagePickerGateway implements ImagePickerGateway {
  const new([ImagePicker? picker]) : _picker = picker;

  final ImagePicker? _picker;

  @override
  Future<List<String>> pickImagePaths() async {
    final picker = _picker ?? ImagePicker();
    final picked = await picker.pickMultiImage();
    return picked.map((f) => f.path).where((p) => p.isNotEmpty).toList();
  }
}
