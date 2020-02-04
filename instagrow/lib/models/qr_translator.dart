import 'dart:collection';

import 'package:instagrow/models/plant.dart';

class QrTranslator {
  static const String separator = '%%%';

  static String encodeQr(Plant plant, LinkedHashMap<dynamic, dynamic> data) {
    String content = plant.id +
        separator +
        data.keys.first.toString() +
        separator +
        data.values.first.toString();
    return content;
  }

  static List<String> decodeQr(String scannedCode) {
    List<String> split = scannedCode.split(separator);
    if (split.length != 3) {
      return null;
    }
    return split;
  }
}
