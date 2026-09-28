import 'package:share_plus/share_plus.dart';

/// Injectable abstraction over file sharing.
///
/// Owned by the files mutation Bloc; UI dispatches a share event and shows
/// feedback from the Bloc listener. Tests inject a fake.
abstract class ShareGateway {
  Future<void> shareFile(String path);
}

class SharePlusGateway implements ShareGateway {
  const new();

  @override
  Future<void> shareFile(String path) {
    return SharePlus.instance.share(ShareParams(files: [XFile(path)]));
  }
}
