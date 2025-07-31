import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

Future<String> createDynamicLink({required String eventId}) async {
  final DynamicLinkParameters parameters = DynamicLinkParameters(
    uriPrefix: 'https://volmore.page.link',
    link: Uri.parse('https://volmore.page.link/event?eventId=$eventId'),
    androidParameters: const AndroidParameters(
      packageName: 'com.maizelabs.volunterring',
    ),
    iosParameters: const IOSParameters(
        bundleId: 'com.maizelabs.volunterring', minimumVersion: '1'),
  );

  final ShortDynamicLink shortDynamicLink =
      await FirebaseDynamicLinks.instance.buildShortLink(parameters);
  final Uri shortUrl = shortDynamicLink.shortUrl;

  return shortUrl.toString();
}

Future<String> createAppLink({required String eventId}) async {
  final String baseUrl = 'https://www.lendavolunteering.com';
  final String fullUrl = '$baseUrl/event/$eventId';
  return fullUrl;
}

