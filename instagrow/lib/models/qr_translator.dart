import 'dart:collection';

import 'dart:convert';

import 'package:instagrow/models/plant.dart';

class QrTranslator {
  static const String separator = '%%';

  static bool addMyPlants(String scannedCode) {
    return true;
  }

  static String encodeQr(Plant plant, LinkedHashMap<dynamic, dynamic> data) {
    String content = plant.id +
        separator +
        data.keys.first.toString() +
        separator +
        data.values.first.toString();
    return content;
    // String encoded = utf8.encode(content).toString();
    // return encoded;
  }

  static List<String> decodeQr(String scannedCode) {
    return scannedCode.split(separator);
    // try {
    //   List<int> bytes = scannedCode
    //       .substring(1, scannedCode.length - 1)
    //       .split(',')
    //       .map((String byte) => int.parse(byte))
    //       .toList();
    //   String decoded = utf8.decode(bytes);
    //   return decoded.split(separator);
    // } catch (e) {
    //   return null;
    // }
  }
}
