import 'dart:collection';

import 'package:flutter_test/flutter_test.dart';
import 'package:instagrow/models/plant.dart';
import 'package:instagrow/models/qr_translator.dart';

void main() {

  String plantId = "PLANTID", qrKey = "-Lxyz725", qrTimestamp = "202002022020";
  String displayedCode =  "$plantId${QrTranslator.separator}$qrKey${QrTranslator.separator}$qrTimestamp";
  test('encodeQr', () {
    
    Plant testPlant = Plant("PLANTID", '', '', '', 0, 0, 0, '', '', false);
    LinkedHashMap qrInstance = LinkedHashMap.fromIterables([qrKey], [qrTimestamp]);
    String encoded = QrTranslator.encodeQr(testPlant, qrInstance);

    expect(encoded, displayedCode);

  });

  test('decodeQr', () {
    String scanned = displayedCode;
        
    List<String> result = QrTranslator.decodeQr(scanned);
    expect(result.length, 3);
    expect(result[0], plantId);
    expect(result[1], qrKey);
    expect(result[2], qrTimestamp);
  });

  test('decodeQrFailed', () {
    String invalidScannedCode = "Hello World";

    List<String> result = QrTranslator.decodeQr(invalidScannedCode);
    expect(result, null);
  });
}
