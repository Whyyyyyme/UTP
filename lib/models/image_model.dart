import 'package:image_picker/image_picker.dart';

class SellImage {
  final XFile? local; // foto baru dari device
  final String? url; // foto lama dari supabase/public url

  const SellImage._({this.local, this.url});

  factory SellImage.local(XFile file) => SellImage._(local: file);
  factory SellImage.url(String url) => SellImage._(url: url);

  bool get isLocal => local != null;
  bool get isUrl => url != null;
}
