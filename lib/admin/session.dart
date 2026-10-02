class Session {
  static String? userId;

  static bool get isLoggedIn => userId != null;
}