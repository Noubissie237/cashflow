
import 'package:url_launcher/url_launcher.dart';

String getLastName(String? fullName) {
  final names = fullName!.split(' ');
  return names.isNotEmpty ? names.last : '';
}

void lienExterne(String link) async {
  final Uri url = Uri.parse(link);
  if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
    throw 'Could not launch $url';
  }
}