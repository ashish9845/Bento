import 'package:file_picker/file_picker.dart';

/// Injectable abstraction over PDF file picking.
///
/// The MutationBloc owns picking via this gateway; UI only dispatches
/// pick events and renders state. The default implementation delegates
/// to `file_picker`; tests inject a fake.
abstract class PdfPickerGateway {
  Future<List<String>> pickPdfPaths();
}

class FilePickerPdfGateway implements PdfPickerGateway {
  const new();

  @override
  Future<List<String>> pickPdfPaths() async {
    final picked = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    return picked
        .where((f) => f.path != null && f.path!.isNotEmpty)
        .map((f) => f.path!)
        .toList();
  }
}
