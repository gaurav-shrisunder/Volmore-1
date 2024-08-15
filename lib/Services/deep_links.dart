import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

Future<String> createDynamicLink(String eventId, String userId) async {
  final DynamicLinkParameters parameters = DynamicLinkParameters(
    uriPrefix: 'https://volmore.page.link',
    link:
        Uri.parse('https://volmore.com/event?eventId=$eventId&userId=$userId'),
    androidParameters: const AndroidParameters(
      packageName: 'com.yourapp',
    ),
    iosParameters: const IOSParameters(
      bundleId: 'com.volmore.app',
      appStoreId: 'your_app_store_id',
    ),
  );

  final ShortDynamicLink shortDynamicLink =
      await FirebaseDynamicLinks.instance.buildShortLink(parameters);
  final Uri shortUrl = shortDynamicLink.shortUrl;

  return shortUrl.toString();
}
