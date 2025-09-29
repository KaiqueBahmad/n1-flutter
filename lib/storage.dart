class Storage {
  static final Map<String, String> _users = {};

  static void addUser(String username, String password) {
    _users[username] = password;
  }

  static String? getPassword(String username) {
    return _users[username];
  }

  static bool checkLogin(String username, String password) {
    return _users[username] == password;
  }

  static bool userExists(String username) {
    return _users.containsKey(username);
  }

  static void updatePassword(String username, String newPassword) {
    if (userExists(username)) {
      _users[username] = newPassword;
    }
  }
}
