List<String> splitPath(String path) {
  return path.split('/').where((p) => p.isNotEmpty).toList();
}

Object? traverseValue(Object? value, List<String> parts) {
  for (final part in parts) {
    if (value is Map<String, dynamic> && value.containsKey(part)) {
      value = value[part];
    } else {
      value = null;
      break;
    }
  }
  return value;
}
