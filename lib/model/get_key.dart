class GetKey {
  static const key = String.fromEnvironment('apiKey');

  static String _getKey() {
    if(key.isNotEmpty) {
      return key;
    }
    return 'not key';
  }

  static String get apiKey => _getKey();
}