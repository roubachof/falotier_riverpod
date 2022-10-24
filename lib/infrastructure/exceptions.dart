class ItemNotFoundException implements Exception {
  final String key;

  ItemNotFoundException(this.key);

  @override
  String toString() {
    return 'Item with key: $key wasn' 't find';
  }
}
