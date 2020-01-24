import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:instagrow/models/qr_translator.dart';
import 'package:instagrow/utils/database_service.dart';

void main() {
  test('queryStringToQr', () async {
    var db = FirebaseDatabase.instance.reference();
    var res = await db.child('qrInstances').child('123').child('-LzI8rnUh84nhhUWO983').child('20200123160617617').once();
    print(res.value);
  });

  test('qrToQueryString', () {
    String scanned = "[45, 76, 122, 73, 56, 114, 110, 85, 104, 56, 52, 110, 104, 104, 85, 87, 79, 57, 56, 51, 37, 37, 50, 48, 50, 48, 48, 49, 50, 51, 49, 54, 48, 54, 49, 55, 54, 49, 55]";
    String result = QrTranslator.decodeQr(scanned);
    print(result);
  });
}