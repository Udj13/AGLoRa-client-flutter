const String myIDPrefix = 'myId=';

String? newInfoParsing(List<String> fields) {
  String? result;

  fields.forEach((field) {
    if (field.trim().startsWith(myIDPrefix)) {
      print(field);
      result = field.substring(myIDPrefix.length, field.length);
    }
  });

  return result;
}
