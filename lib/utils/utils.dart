
String getLastName(String? fullName) {
  final names = fullName!.split(' ');
  return names.isNotEmpty ? names.last : '';
}