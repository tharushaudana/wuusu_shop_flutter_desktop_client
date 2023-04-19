class Funcs {
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  static bool isExpiredDate(String datestr) {
    final now = DateTime.now();
    final expirationDate = DateTime.parse(datestr);
    return expirationDate.isBefore(now);
  }
}
