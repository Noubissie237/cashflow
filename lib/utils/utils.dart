import 'package:cashflow/models/caisse.dart';
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

void lienExterneWithMessage(String link, {String? message}) async {
  final Uri url = Uri.parse(
    message != null ? '$link?text=${Uri.encodeComponent(message)}' : link,
  );
  if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
    throw 'Could not launch $url';
  }
}

double calculateTotal(List<Caisse> caisseList) {
  return caisseList.fold(0, (sum, caisse) => sum + caisse.montant);
}

double roundToNextMultipleOf25(double amount) {
  return (amount / 25).ceil() * 25;
}
